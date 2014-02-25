class ManipulacionFicheros


	def initialize
		@datosProyectos= Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
	end

  attr_reader :datosProyectos

def mostrarDatosProyecto
  string=""
  @datosProyectos.each {|k,v| string << "\n--- Proyecto #{k} --- \n\n #{mostrarPaquetes(@datosProyectos[k])}"}
  string
end

def mostrarPaquetes(paquetes)
  string=""
  paquetes.each {|k,v| string << "Paquete #{k} \n #{mostrarClases(paquetes[k])}"}
  string
end

def mostrarClases(clases)
  string=""
  clases.each{|k,v| string << "Clase #{k} \n #{mostrarMetricas(clases[k])}"}
  string
end

def mostrarMetricas(metricas)
  "Complejidad ciclomatica: #{metricas["complejidad"]} \n Lineas de codigo: #{metricas["loc"]}\n\n-------\n\n"
end

def tratar_fichero(nombreArchivo)
  # Ficheros del formato nombreProyecto12345-complejidad-ciclo.csv o nombreProyecto12345-lineas-codigo.csv
  nombreArray= (File.basename(nombreArchivo)).split('-')
  nombre= nombreArray.first
  nombreProyecto=nombre.scan(/\d+|\D+/).first
  nombreProyecto = nombreArray.first
  nombreArray.delete_at(0)

  tipo_archivo= nombreArray.join('-')

  File.open(nombreArchivo) do|fichero|

    fichero.gets

    #fichero.each do |linea|
      linea=fichero.gets
      array=linea.split(',')

      tratar_fichero_complejidad_ciclomatica(array,nombreProyecto) if tipo_archivo.eql?("complejidad-ciclo.csv")
      tratar_fichero_lineas_codigo(array,nombreProyecto) if tipo_archivo.eql?("lineas-codigo.csv")
    #end
  end

end

def tratar_fichero_complejidad_ciclomatica(array,nombreProyecto)
  paquete=array[1]
  nombreClase=array[2]

  mensajeComplejidad=array[5]
  complejidad_espacios= mensajeComplejidad.scan(/\s+\d+\s+/)
  lista_complejidad = complejidad_espacios.collect() {|palabra| palabra.strip()}
  complejidad=lista_complejidad.first

  @datosProyectos[nombreProyecto][paquete][nombreClase]["complejidad"]=complejidad
end

def tratar_fichero_lineas_codigo(array,nombreProyecto)
  paquete=array[1]
  nombreClase=array[2]
  @datosProyectos[nombreProyecto][paquete][nombreClase]["loc"]=10 #debe sumar todas las ocurrencias
end

def recorrer_archivos_directorio(dir, level=0)
  #puts "#{' '*level}#{dir}"
  Dir["#{dir}/*"].each do |nombreArchivo|
    if !File.directory?(nombreArchivo) then
       tratar_fichero(nombreArchivo)
    end
  end
end

end

manipular= ManipulacionFicheros.new

#manipular.recorrer_archivos_directorio('D:/prueba/informes')

manipular.recorrer_archivos_directorio('C:/Users/Ana/Dropbox/Proyecto/0 API GITHUB/tratar/informe')

puts manipular.mostrarDatosProyecto #ojo que crea hashes vacios si no estan