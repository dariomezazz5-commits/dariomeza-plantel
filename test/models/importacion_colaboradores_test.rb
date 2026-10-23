require "test_helper"

class ImportacionColaboradoresTest < ActiveSupport::TestCase
  def importar(contenido)
    archivo = Tempfile.new([ "colaboradores", ".csv" ])
    archivo.write(contenido)
    archivo.close
    ImportacionColaboradores.new(archivo.path, ".csv").ejecutar
  end

  ENCABEZADO = "nombre;rut;email;cargo;área;sede;fecha_ingreso;contrato;estado;saldo_vacaciones;rut_jefatura\n"

  test "crea, actualiza y asigna jefatura aunque venga más abajo" do
    r = importar(ENCABEZADO +
      "Luis Soto Vera;9.876.543-3;lsoto@andes.cl;Bodeguero;Logística;Santiago;01-03-2024;;;5;8.765.432-K\n" +
      "Ana Pino Ruiz;8765432k;apino@andes.cl;Jefa de Bodega;Logística;Santiago;15/06/2023;Plazo fijo;Activo;3;\n" +
      "Valentina Muñoz Díaz;17.445.208-3;vmunoz@industriasandes.cl;Jefa de Procesos;Operaciones;Concepción;2020-01-13;;;17;\n")
    assert r.exitosa?, r.errores.inspect
    assert_equal 2, r.creados
    assert_equal 1, r.actualizados
    luis = Colaborador.find_by(rut: "9.876.543-3")
    assert_equal "Ana Pino Ruiz", luis.jefe.nombre
    assert_equal "Jefa de Procesos", colaboradores(:valentina).reload.cargo
  end

  test "es todo o nada" do
    assert_no_difference -> { Colaborador.count } do
      r = importar(ENCABEZADO +
        "Luis Soto Vera;9.876.543-3;lsoto@andes.cl;Bodeguero;Logística;Santiago;01-03-2024;;;5;\n" +
        "Mal Rut;11.111.111-2;x@andes.cl;Cargo;Área;Sede;01-01-2020;;;;\n")
      assert_not r.exitosa?
      assert_equal 3, r.errores.first.first
    end
  end

  test "avisa si faltan columnas" do
    r = importar("nombre;rut\nLuis;9.876.543-3\n")
    assert_match "Faltan columnas", r.errores.first.last
  end
end
