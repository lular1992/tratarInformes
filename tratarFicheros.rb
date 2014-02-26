class ManipulacionFicheros


	def initialize
		#@datosProyectos= Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    @datosProyectos= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{ |h3,k3| h3[k3] = Hash.new {|h4,k4| h4[k4]=  0}} } }
    @versiones= Hash.new { |hash, key| hash[key] =""}
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

    nombreArch= (File.basename(nombreArchivo))

    if !nombreArch.eql?("0-ultimoPush.txt")
      nombreArray= nombreArch.scan(/\d+|\D+/)
      longitud = nombreArray.size

      #por si el nombre del proyecto contiene numeros
      nombreProyecto= longitud > 3 ? nombreArray.take(longitud-2).join : nombreArray.first

      tipo_archivo = nombreArray.last[1..-1]

      metrica=""
    end

    contadorFilas=0

    File.open(nombreArchivo) do|fichero|

      fichero.gets

      fichero.each do |linea|

        if nombreArch.eql?("0-ultimoPush.txt")
          #El nombre de proyecto esta en la linea 1
          # en la 3 la fecha
          contadorFilas+=1

          @proyecto=linea if contadorFilas==1
          @fecha=linea if contadorFilas==3


          if contadorFilas==6
            contadorFilas=0
            @versiones[@proyecto]=@fecha
          end

        else
          array=linea.split(',')
          paquete=array[1]
          nombreClase=array[2]
          mensaje=array[5]
          lista_mensaje= mensaje.scan(/\d+/)
      
          #por si las clases contienen numeros
          valor_metrica = lista_mensaje.size > 2 ? lista_mensaje.drop(lista_mensaje.size-2).first : lista_mensaje.first if tipo_archivo.eql?("complejidad-ciclo.csv")

          valor_metrica = lista_mensaje.last if tipo_archivo.eql?("lineas-codigo.csv")

          metrica="complejidad" if tipo_archivo.eql?("complejidad-ciclo.csv")
          metrica="loc" if tipo_archivo.eql?("lineas-codigo.csv")

          @datosProyectos[nombreProyecto][paquete][nombreClase][metrica]+=valor_metrica.to_i  if !metrica.empty?

        end
      end
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

  def mostrarVersiones
    string=""
    @versiones.each {|k,v| string << "#{k} #{@versiones[k]}\n"}
    string
  end

end



#ojo que los loc pueden ser 0, pmd no cuenta el nombre de clase como linea de codigo

manipular= ManipulacionFicheros.new

manipular.recorrer_archivos_directorio('C:/Users/Ana/Desktop/informesGit/tratar/informe')

File.open('C:/Users/Ana/Desktop/informesGit/tratar/hash_complejidad.txt','w') do |s|
  #manipular.recorrer_archivos_directorio('C:/Users/Ana/Desktop/informesGit/tratar/informe',s)
  s.puts manipular.mostrarDatosProyecto
end

File.open('C:/Users/Ana/Desktop/informesGit/tratar/versiones.txt','w') do |s|
  s.puts manipular.mostrarVersiones
end
