require './proyecto.rb'
require './metrica.rb'
require './tratarFicheros.rb'

manipular= ManipulacionFicheros.new

lista_proyectos=manipular.cargarDatosGeneralesProyectos('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/informe/0-ultimoPush.txt')

  #File.open('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/debug.txt','w') do |f|
	manipular.recorrer_archivos_directorio('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/informe')
  #end

hash_proyectos=manipular.datos_proyectos

lista_proyectos.each do |proyecto|
  complejidad_ciclomatica= Metrica.new("Complejidad ciclomatica total",manipular.complejidadCiclomaticaDelProyecto(hash_proyectos[proyecto.nombre]))
  loc=Metrica.new("Lineas de codigo totales",manipular.locDelProyecto(hash_proyectos[proyecto.nombre]))
  densidad_complejidad= Metrica.new("Densidad complejidad ciclomatica",manipular.densidadComplejidadCiclomatica(complejidad_ciclomatica,loc))
  lineas_codigo_repetidas= Metrica.new("Lineas codigo repetido",manipular.numLineasCodigoRepetidas(proyecto.nombre))

  proyecto.metricas[:complejidad_ciclomatica]=complejidad_ciclomatica
  proyecto.metricas[:loc]=loc
  proyecto.metricas[:densidad_complejidad]=densidad_complejidad
  proyecto.metricas[:lineas_codigo_repetidas]=lineas_codigo_repetidas
end

lista_proyectos.sort! { |proyecto1,proyecto2| proyecto2.metricas[:densidad_complejidad].valor <=> proyecto1.metricas[:densidad_complejidad].valor} 


manipular.guardarEnFichero('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/datos-proyectos.txt',lista_proyectos)

manipular.guardarEnFormatoCsv('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/datos-proyectos.csv',lista_proyectos)
