class ManipulacionFicheros

  require './proyecto.rb'

	def initialize
		#@datosProyectos= Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    @datosProyectos= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{ |h3,k3| h3[k3] = Hash.new {|h4,k4| h4[k4]=  0}} } }
    @versiones= Hash.new { |hash, key| hash[key] =""}
    @urls=Hash.new { |hash, key| hash[key] =""}
	end

  attr_reader :datosProyectos, :versiones, :urls

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

      #por defecto guarda saltos de carro en cada linea, de ahi el strip
      fichero.each do |linea|

        if nombreArch.eql?("0-ultimoPush.txt")
          #El nombre de proyecto esta en la linea 1
          # en la 3 la fecha
          contadorFilas+=1

          @proyecto=linea.strip if contadorFilas==1
          @url=linea.strip if contadorFilas==2
          @fecha=linea.strip if contadorFilas==3


          if contadorFilas==3
            contadorFilas=0
            @versiones[@proyecto]=@fecha
            @urls[@proyecto]=@url
          end

        else
          array=linea.split(',')
          paquete=array[1]
          nombreClase=array[2]
          #quitar comillas del string
          paquete.tr!('"',"")
          nombreClase.tr!('"',"")

          mensaje=array[5]
          lista_mensaje= mensaje.scan(/\s+\d+/)

      
          #por si las clases contienen numeros
          if tipo_archivo.eql?("complejidad-ciclo.csv")
            valor_metrica=lista_mensaje.first.strip
            #valor_metrica = lista_mensaje.size > 2 ? lista_mensaje.drop(lista_mensaje.size-2).first : lista_mensaje.first
          end

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

  def densidadComplejidadCiclomatica(complejidad_ciclomatica_total,loc_totales)
    (complejidad_ciclomatica_total.to_f/loc_totales)
  end

  def complejidadCiclomaticaDelProyecto(proyecto)
    complejidad_ciclomatica_total=0
    proyecto.each {|k,v| complejidad_ciclomatica_total+=complejidad_ciclomatica_por_paquete(proyecto[k])}
    complejidad_ciclomatica_total
  end

  def locDelProyecto(proyecto)
    loc_totales=0
    proyecto.each {|k,v| loc_totales+=loc_por_paquete(proyecto[k])}
    loc_totales
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

  def versionesAfichero(nombre_fichero)
    File.open(nombre_fichero,'w') do |f|
      f.puts mostrarVersiones
    end
  end

  def datosProyectoAfichero(nombre_fichero)
    File.open(nombre_fichero,'w') do |f|
      f.puts mostrarDatosProyecto
    end
  end

  def calculoDensidadAfichero(nombre_fichero)
    File.open(nombre_fichero,'w') do |f|
      datosProyectos.each do |k,v|
        f.puts "Proyecto #{k}" 

        complejidad_ciclomatica_total= complejidadCiclomaticaDelProyecto(datosProyectos[k])
        loc_totales = locDelProyecto(datosProyectos[k])

        f.puts "CC total: #{complejidad_ciclomatica_total}"
        f.puts "loc total: #{loc_totales}"
        f.print "Densidad de la complejidad ciclomatica: "
        f.puts densidadComplejidadCiclomatica(complejidad_ciclomatica_total,loc_totales)
        f.puts "\n"
      end
    end
  end
end

def guardarEnFichero(nombre_fichero,objeto_a_guardar)
  File.open(nombre_fichero,'w') do |f|
    f.puts objeto_a_guardar
  end
end


manipular= ManipulacionFicheros.new

manipular.recorrer_archivos_directorio('C:/Users/Ana/Desktop/informesGit/tratar/informe')

lista_proyectos = Array.new

manipular.datosProyectos.each do |k,v|
  nombre_proyecto=k
  url=manipular.urls[k]
  version=manipular.versiones[k]
  complejidad_ciclomatica= manipular.complejidadCiclomaticaDelProyecto(manipular.datosProyectos[k])
  loc=manipular.locDelProyecto(manipular.datosProyectos[k])
  densidad_complejidad= manipular.densidadComplejidadCiclomatica(complejidad_ciclomatica,loc)

  proyecto= Proyecto.new(nombre_proyecto,url,version,complejidad_ciclomatica,loc,densidad_complejidad)

  lista_proyectos << proyecto

end

lista_proyectos.sort! { |x,y| y.densidad_complejidad <=> x.densidad_complejidad} 

manipular.datosProyectoAfichero('C:/Users/Ana/Desktop/informesGit/tratar/datos_proyectos.txt')
guardarEnFichero('C:/Users/Ana/Desktop/informesGit/tratar/proyectos.txt',lista_proyectos)

#se guardan las \ como \\
#puts manipular.datosProyectos["mongo-java-driver"]["example"]["F:\\prueba\\mongo-java-driver2224750128830639995\\src\\examples\\example\\DefaultSecurityCallbackHandler.java"]["loc"]

#manipular.datosProyectoAfichero('C:/Users/Ana/Desktop/informesGit/tratar/datos_proyectos.txt')

#manipular.versionesAfichero('C:/Users/kc/Desktop/informesGit/tratar/versiones.txt')

#manipular.calculoDensidadAfichero('C:/Users/kc/Desktop/informesGit/tratar/densidad_cc.txt')

