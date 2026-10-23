require "test_helper"

class FlujoTest < ActionDispatch::IntegrationTest
  test "sin sesión pide ingresar" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "ingreso y salida" do
    post session_path, params: { email_address: "camila@industriasandes.cl", password: CLAVE }
    assert_redirected_to root_path
    follow_redirect!
    assert_select "h1", /Camila/
    assert_equal "sesion.iniciada", ActsAsTenant.without_tenant { RegistroAuditoria.last.accion }

    delete session_path
    assert_redirected_to new_session_path
  end

  test "contraseña incorrecta" do
    post session_path, params: { email_address: "camila@industriasandes.cl", password: "otra-cosa-123" }
    assert_redirected_to new_session_path(email_address: "camila@industriasandes.cl")
  end

  test "ingreso con verificación en dos pasos" do
    user = users(:camila)
    secret = ROTP::Base32.random
    user.update!(otp_secret: secret, otp_activado_en: Time.current)

    post session_path, params: { email_address: user.email_address, password: CLAVE }
    assert_redirected_to new_verificacion_path
    post verificacion_path, params: { codigo: "000000" }
    assert_response :unprocessable_entity
    post verificacion_path, params: { codigo: ROTP::TOTP.new(secret).now }
    assert_redirected_to root_path
  end

  test "admin: páginas principales" do
    sign_in_as users(:camila)
    get root_path
    assert_select ".nav-badge", "2"
    get colaboradores_path
    assert_select "#colaboradores_conteo", /4 personas/
    get auditoria_path
    assert_response :success
    get new_importacion_path
    assert_response :success
  end

  test "admin crea colaborador con acceso e invitación" do
    sign_in_as users(:camila)
    assert_difference -> { User.count } do
      assert_enqueued_email_with PasswordsMailer, :invitacion, args: ->(args) { args.first.is_a?(User) } do
        post colaboradores_path, params: {
          colaborador: { nombre: "Luis Soto Vera", rut: "98765433", email: "lsoto@industriasandes.cl", cargo: "Bodeguero",
                         area: "Logística", sede: "Santiago", ingreso: "2024-03-01", contrato: "Indefinido", estado: "Activo",
                         saldo_vacaciones: 5, jefe_id: colaboradores(:benjamin).id },
          acceso: { habilitar: "1", rol: "colaborador" }
        }
      end
    end
    nuevo = User.find_by(email_address: "lsoto@industriasandes.cl")
    assert_redirected_to colaboradores_path(ficha: nuevo.colaborador_id)
    assert_equal "9.876.543-3", nuevo.colaborador.rut
  end

  test "jefatura no puede editar ni aprobar fuera de su equipo" do
    sign_in_as users(:benjamin)
    get new_colaborador_path
    assert_redirected_to root_path

    patch aprobar_solicitud_path(solicitudes(:permiso_matias))
    assert_redirected_to root_path
    assert solicitudes(:permiso_matias).reload.pendiente?

    patch aprobar_solicitud_path(solicitudes(:vacaciones_valentina)), headers: { "HTTP_REFERER" => ausencias_url }
    assert_equal "Aprobada", solicitudes(:vacaciones_valentina).reload.estado
  end

  test "colaborador solo ve lo suyo y pide para sí" do
    sign_in_as users(:valentina)
    get root_path
    assert_redirected_to ausencias_path
    get colaborador_path(colaboradores(:matias)), headers: { "Turbo-Frame" => "drawer" }
    assert_redirected_to root_path

    post solicitudes_path, params: { solicitud: { colaborador_id: colaboradores(:matias).id, tipo: "Vacaciones", desde: "2026-12-01", hasta: "2026-12-02" } }
    assert_response :unprocessable_entity

    assert_difference -> { ActsAsTenant.without_tenant { Solicitud.count } } do
      post solicitudes_path, params: { solicitud: { colaborador_id: colaboradores(:valentina).id, tipo: "Vacaciones", desde: "2026-12-01", hasta: "2026-12-02" } }
    end
    assert_redirected_to ausencias_path(tab: "pend")
  end

  test "una empresa nunca ve datos de otra" do
    sign_in_as users(:rosa)
    get colaboradores_path
    assert_select "#colaboradores_conteo", /1 personas/
    assert_no_match "Valentina", response.body

    get colaborador_path(colaboradores(:valentina)), headers: { "Turbo-Frame" => "drawer" }
    assert_redirected_to root_path
    patch aprobar_solicitud_path(solicitudes(:vacaciones_valentina))
    assert_redirected_to root_path
    assert solicitudes(:vacaciones_valentina).reload.pendiente?
  end

  test "búsqueda responde con turbo stream" do
    sign_in_as users(:camila)
    get colaboradores_path(q: "ingeniera", area: "Todas"), as: :turbo_stream
    assert_match "1 de 4 personas", response.body
  end

  test "importación desde la web" do
    sign_in_as users(:camila)
    archivo = Rack::Test::UploadedFile.new(StringIO.new("nombre;rut;email;cargo;area;sede;fecha_ingreso\nLuis Soto Vera;9.876.543-3;lsoto@andes.cl;Bodeguero;Logística;Santiago;01-03-2024\n"), "text/csv", original_filename: "gente.csv")
    post importaciones_path, params: { archivo: }
    assert_redirected_to colaboradores_path
    assert_equal "colaborador.importacion", ActsAsTenant.without_tenant { RegistroAuditoria.last.accion }
  end
end
