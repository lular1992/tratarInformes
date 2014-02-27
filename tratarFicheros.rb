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

          if tipo_archivo.eql?("complejidad-ciclo.csv")
            if !mensaje.include?("class")
              @datosProyectos[nombreProyecto][paquete][nombreClase]["complejidad"]+=valor_metrica.to_i
            end
          end

            @datosProyectos[nombreProyecto][paquete][nombreClase]["loc"]+=valor_metrica.to_i if tipo_archivo.eql?("lineas-codigo.csv")

        end
      end
    end
  end

  def densidad_complejidad_ciclomatica_de_proyecto(proyecto,fichero)
    complejidad_ciclomatica_total=0
    loc_totales=0
    proyecto.each {|k,v| complejidad_ciclomatica_total+=complejidad_ciclomatica_por_paquete(proyecto[k])}
    proyecto.each {|k,v| loc_totales+=loc_por_paquete(proyecto[k])}

    fichero.puts "CC total: #{complejidad_ciclomatica_total}"

    fichero.puts "loc total: #{loc_totales}"

    fichero.puts "Densidad: #{complejidad_ciclomatica_total.to_f/loc_totales}"
  end

  def complejidad_ciclomatica_por_paquete(paquete)
    complejidad_ciclomatica_paquete=0
    paquete.each {|k,v| complejidad_ciclomatica_paquete+=complejidad_ciclomatica_por_clase(paquete[k])}
    complejidad_ciclomatica_paquete
  end

  def loc_por_paquete(paquete)
    loc_paquete=0
    paquete.each {|k,v| loc_paquete+=loc_por_clase(paquete[k])}
    loc_paquete
  end

  def complejidad_ciclomatica_por_clase(clase)
    clase["complejidad"]
  end

    def loc_por_clase(clase)
    clase["loc"]
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


manipular= ManipulacionFicheros.new

manipular.recorrer_archivos_directorio('C:/Users/kc/Desktop/informesGit/tratar/informe')


#File.open('C:/Users/kc/Desktop/informesGit/tratar/hash_complejidad.txt','w') do |s|
  #s.puts manipular.mostrarDatosProyecto
#end

File.open('C:/Users/kc/Desktop/informesGit/tratar/versiones.txt','w') do |s|
  s.puts manipular.mostrarVersiones
end

File.open('C:/Users/kc/Desktop/informesGit/tratar/densidad_cc.txt','w') do |s|
    manipular.datosProyectos.each do |k,v|
       s.puts "Proyecto #{k}" 
       manipular.densidad_complejidad_ciclomatica_de_proyecto(manipular.datosProyectos[k],s)
       s.puts "\n"
    end
end
