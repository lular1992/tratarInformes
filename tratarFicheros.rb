class ManipulacionFicheros

  #Ejecutar como ruby  -E UTF-8 tratarFicheros.rb

  require './proyecto.rb'
  require './metrica.rb'
  require 'yaml'

	def initialize
		#@datosProyectos= Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    @datos_tamanio= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{ |h3,k3| h3[k3] = Hash.new {|h4,k4| h4[k4]= Hash.new{|h5,k5| h5[k5]=0}}}}}
    @datos_resto_metricas= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{ |h3,k3| h3[k3] = Hash.new {|h4,k4| h4[k4]=Hash.new{|h5,k5| h5[k5]=Array.new}}}}}
    @codigo_repetido= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{|h3,k3| h3[k3]=0}}}

	end

  attr_reader :datos_tamanio,:datos_resto_metricas,:codigo_repetido


  def serializarDatosProyectos(ruta_archivo,objeto_a_serializar)
    File.open(ruta_archivo, 'w') { |f| f.puts objeto_a_serializar.to_yaml }
  end

  def deserializarDatosProyectos(ruta_archivo,variable)
    instance_variable_set("@#{variable}", YAML.load_file(ruta_archivo))
  end


  def mostrarDatosTamanio
    string=""
    datos_tamanio.each {|k,v| string << "\n--- Proyecto #{k} --- \n\n #{mostrarPaquetes(datos_tamanio[k])}"}
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
    "Complejidad ciclomatica: #{metricas[:complejidad]} \n Lineas de codigo: #{metricas[:loc]}\n\n-------\n\n"
  end

  def cargarDatosGeneralesProyectos(nombre_fichero)
    # El fichero tiene el siguiente formato
    # Nombre, descripcion, url, homepage, language, owner, pushed at, 
    # created at, forks, open issues,watchers, size, tiene descargas, tiene wiki

    lista_proyectos=Array.new

    File.open(nombre_fichero) do |fichero|
      contador_filas=0
      array_lineas= fichero.to_a

      while(!array_lineas.empty?)
        datos_de_un_proyecto = array_lineas.take(14)
        array_lineas = array_lineas.drop(14)

        nombre=datos_de_un_proyecto[0].strip
        descripcion=datos_de_un_proyecto[1].strip
        url=datos_de_un_proyecto[2].strip
        homepage=datos_de_un_proyecto[3].strip
        language=datos_de_un_proyecto[4].strip
        owner=datos_de_un_proyecto[5].strip
        pushed_at=datos_de_un_proyecto[6].strip
        created_at=datos_de_un_proyecto[7].strip
        forks=datos_de_un_proyecto[8].strip
        open_issues=datos_de_un_proyecto[9].strip
        watchers=datos_de_un_proyecto[10].strip
        size=datos_de_un_proyecto[11].strip
        tiene_descargas=datos_de_un_proyecto[12].strip
        tiene_wiki=datos_de_un_proyecto[13].strip

        proyecto=Proyecto.new(nombre,descripcion,url,homepage,language,owner,pushed_at,created_at, forks, open_issues, watchers, size, tiene_descargas, tiene_wiki)
        lista_proyectos << proyecto
      end

      lista_proyectos
    end
  end


  def tratar_fichero(ruta_archivo)
    # Ficheros del formato nombreProyecto_informe_complejidad-ciclo.csv o nombreProyecto_informe_lineas-codigo.csv
    nombre_archivo= (File.basename(ruta_archivo))

    if !nombre_archivo.eql?("0-ultimoPush.txt")
      nombre_arch_array= nombre_archivo.split("_informe_")
      nombre_proyecto=nombre_arch_array.first
      tipo_archivo=nombre_arch_array.last
    end


    File.open(ruta_archivo) do|fichero|
      array_lineas_fichero=fichero.to_a

      #Primeras lineas que contienen la estructura del archivo, se omiten
      array_lineas_fichero=array_lineas_fichero.drop(1)

      array_lineas_fichero=array_lineas_fichero.drop(1) if tipo_archivo.eql?("coupling.csv") 

      array_lineas_fichero.each do |linea|
        if !nombre_archivo.eql?("0-ultimoPush.txt")
          #los mensajes dentro del informe de design tienen comas
          if tipo_archivo.eql?("design.csv") 
            array=linea.split('"')
          else
            array=linea.split(',') 
          end

          if tipo_archivo.eql?("codigo-repetido.csv") 
            if !linea.eql?("\n")
              #25,103,2,
              #59,D:\prueba\proyectos\acra\src\main\java\org\acra\collector\SettingsCollector.java,
              #89,D:\prueba\proyectos\acra\src\main\java\org\acra\collector\SettingsCollector.java
            
              indice=codigo_repetido.size
              @codigo_repetido[nombre_proyecto][indice][:num_lineas_codigo_repetidas]=array[0].to_i
              @codigo_repetido[nombre_proyecto][indice][:num_tokens_repetidos]=array[1].to_i
              @codigo_repetido[nombre_proyecto][indice][:num_ocurrencias]=array[2].to_i
              @codigo_repetido[nombre_proyecto][indice][:secuencia_ocurrencias]=array.drop(3).join(" ")
            end
          else
            paquete=array[1]
            nombre_clase=array[2]

            #quitar comillas del string
            paquete.tr!('"',"")
            nombre_clase.tr!('"',"")

            mensaje=array[5]
            lista_mensaje= mensaje.scan(/\s+\d+/)

            indiceRegla=7
            indiceLinea=4

            case tipo_archivo

              when "complejidad-ciclo.csv"
                valor_metrica=lista_mensaje.first.strip
                if !mensaje.include?("class")
                  metodo=mensaje.split("'").drop(1).first
                  @datos_tamanio[nombre_proyecto][paquete][nombre_clase][metodo][:complejidad]=valor_metrica.to_i
                end

              when "lineas-codigo.csv"
                valor_metrica = lista_mensaje.last
                metodo=mensaje.split.drop(2).first.split("()").first
                @datos_tamanio[nombre_proyecto][paquete][nombre_clase][metodo][:loc]=valor_metrica.to_i

              when "comentarios.csv"
                tipo_metrica=:comentarios

              when "design.csv"
                tipo_metrica=:design
                paquete=array[3]
                nombre_clase=array[5]
                regla=array[15]
                linea=array[9]
             
                @datos_resto_metricas[nombre_proyecto][paquete][nombre_clase][tipo_metrica][regla] << linea

              when "unused-code.csv"
                tipo_metrica=:unused_code

              when "coupling.csv" 
                tipo_metrica=:coupling

              when "empty-code.csv"
                tipo_metrica=:empty_code

              when "junit.csv"
                tipo_metrica=:junit

              end

              if !tipo_archivo.eql?("complejidad-ciclo.csv") && !tipo_archivo.eql?("lineas-codigo.csv") && !tipo_archivo.eql?("design.csv") 
                regla=array[7].tr!('"',"")
                regla=regla.strip if regla!=nil
                linea=array[4].tr!('"',"")
             
                @datos_resto_metricas[nombre_proyecto][paquete][nombre_clase][tipo_metrica][regla] << linea
              end

          end
        end
      end
    end
  end

  def numLineasCodigoRepetidas(proyecto)
    num_lineas_codigo_repetidas_totales=0
    codigo_repetido[proyecto].each{|k,v| num_lineas_codigo_repetidas_totales+= codigo_repetido[proyecto][k][:num_lineas_codigo_repetidas]}
    num_lineas_codigo_repetidas_totales
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
    complejidad_clase=0
    clase.each{|k,v| complejidad_clase+= clase[k][:complejidad]}
    complejidad_clase
  end

  def loc_por_clase(clase)
    loc_clase=0
    clase.each{|k,v| loc_clase+=clase[k][:loc]}
    loc_clase
  end

  def recorrer_archivos_directorio(dir, level=0)
    Dir["#{dir}/*"].each do |nombreArchivo|
      if !File.directory?(nombreArchivo) then
         tratar_fichero(nombreArchivo)
      end
    end
  end

  def datosProyectoAfichero(nombre_fichero)
    File.open(nombre_fichero,'w') do |f|
      f.puts mostrarDatosProyecto
    end
  end


def guardarEnFichero(nombre_fichero,objeto_a_guardar)
  #no guarda en UTF-8
  File.open(nombre_fichero,'w') do |f|
    f.puts "#{objeto_a_guardar.size} proyectos"
    f.puts objeto_a_guardar
  end
end


def guardarEnFormatoCsv(nombre_fichero,lista_proyectos)
  cadena=""
  File.open(nombre_fichero,'w') do |f|
    f.puts "nombre,descripcion,url,homepage,language,owner,pushed_at,created_at,forks,open_issues,watchers,size,tiene_descargas,tiene_wiki,complejidad_ciclomatica,loc,densidad_complejidad,num_lineas_codigo_repetidas"
    lista_proyectos.each do |proyecto|
      cadena ="#{proyecto.nombre},#{proyecto.descripcion},#{proyecto.url},#{proyecto.homepage},#{proyecto.language},#{proyecto.owner}," <<
      "#{proyecto.pushed_at},#{proyecto.created_at},#{proyecto.forks},#{proyecto.open_issues},#{proyecto.watchers},#{proyecto.size}," <<
      "#{proyecto.tiene_descargas},#{proyecto.tiene_wiki},"
      proyecto.metricas.each{|k,v| cadena << "#{proyecto.metricas[k].valor},"}
      f.puts cadena
    end
  end
end

end

