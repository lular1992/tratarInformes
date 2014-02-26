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
  # o con - en el nombre neo4j-tutorial
  nombreArray= (File.basename(nombreArchivo)).scan(/\d+|\D+/)
  longitud = nombreArray.size

  #por si el nombre del proyecto contiene numeros
  if longitud > 3
    nombreProyecto= nombreArray.take(longitud-2).join
  else 
  nombreProyecto= nombreArray.first
  end

  tipo_archivo = nombreArray.last[1..-1]


  File.open(nombreArchivo) do|fichero|

    fichero.gets

    #fichero.each do |linea|
      linea=fichero.gets
      array=linea.split(',')

      tratar_fichero_complejidad_ciclomatica(array,nombreProyecto) if tipo_archivo.eql?("complejidad-ciclo.csv")
      #tratar_fichero_lineas_codigo(array,nombreProyecto) if tipo_archivo.eql?("lineas-codigo.csv")
      #falta el de versiones
    #end
  end

end

def tratar_fichero_complejidad_ciclomatica(array,nombreProyecto)

  paquete=array[1]
  nombreClase=array[2]
  @datosProyectos[nombreProyecto][paquete][nombreClase]["complejidad"]=0 if @datosProyectos[nombreProyecto][paquete][nombreClase]["complejidad"].empty?

  mensajeComplejidad=array[5]
  complejidad_espacios= mensajeComplejidad.scan(/\s+\d+\s+/)
  lista_complejidad = complejidad_espacios.collect() {|palabra| palabra.strip()}
  complejidad=lista_complejidad.first


  @datosProyectos[nombreProyecto][paquete][nombreClase]["complejidad"]+=complejidad.to_i


end

def tratar_fichero_lineas_codigo(array,nombreProyecto)
  paquete=array[1]
  nombreClase=array[2]
  num_lineas_codigo=1

  if @datosProyectos[nombreProyecto][paquete][nombreClase]["loc"]==nil
    @datosProyectos[nombreProyecto][paquete][nombreClase]["loc"]= num_lineas_codigo
  else
    #debe sumar todas las ocurrencias
    @datosProyectos[nombreProyecto][paquete][nombreClase]["loc"]+= num_lineas_codigo 
  end
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

#manipular.recorrer_archivos_directorio('C:/Users/Ana/Dropbox/Proyecto/0 API GITHUB/tratar/informe')

manipular.recorrer_archivos_directorio('C:/Users/kc/Desktop/informesGit/tratar/informe')

File.open('C:/Users/kc/Desktop/informesGit/tratar/hash_complejidad.txt','w') do |s|
s.puts manipular.mostrarDatosProyecto
end

#puts manipular.mostrarDatosProyecto #ojo que crea hashes vacios si no estan