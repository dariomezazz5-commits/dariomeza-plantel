require "test_helper"

class FlujoTest < ActionDispatch::IntegrationTest
  test "páginas principales" do
    get root_path
    assert_response :success
    assert_select "h1", /Camila/
    assert_select ".nav-badge", "1"

    get colaboradores_path
    assert_response :success
    assert_select "#colaboradores_conteo", /2 personas/

    get ausencias_path
    assert_response :success
    assert_select "tbody tr", 1
  end

  test "búsqueda responde con turbo stream" do
    get colaboradores_path(q: "ingeniera", area: "Todas"), as: :turbo_stream
    assert_response :success
    assert_match "1 de 2 personas", response.body
  end

  test "ficha solo dentro del frame" do
    c = colaboradores(:valentina)
    get colaborador_path(c)
    assert_redirected_to colaboradores_path(ficha: c.id)

    get colaborador_path(c), headers: { "Turbo-Frame" => "drawer" }
    assert_response :success
    assert_select "#ficha-nombre", c.nombre
  end

  test "aprobar, deshacer y crear solicitud" do
    s = solicitudes(:vacaciones_valentina)
    patch aprobar_solicitud_path(s), headers: { "HTTP_REFERER" => ausencias_url }
    assert_redirected_to ausencias_url
    assert_equal "Aprobada", s.reload.estado

    get ausencias_path(tab: "done")
    assert_select "button", "Deshacer"
    patch deshacer_solicitud_path(s)
    assert s.reload.pendiente?

    assert_difference -> { Solicitud.pendientes.count } do
      post solicitudes_path, params: { solicitud: { colaborador_id: colaboradores(:camila).id, tipo: "Vacaciones", desde: "2026-11-02", hasta: "2026-11-06" } }
    end
    assert_redirected_to ausencias_path(tab: "pend")
  end

  test "solicitud inválida reabre el diálogo" do
    post solicitudes_path, params: { solicitud: { colaborador_id: "", tipo: "Vacaciones", desde: "2026-11-06", hasta: "2026-11-02" } }
    assert_response :unprocessable_entity
    assert_select ".dialog .form-errors"
  end
end
