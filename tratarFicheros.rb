class ManipulacionFicheros

  #Ejecutar como ruby  -E UTF-8 tratarFicheros.rb

  require './proyecto.rb'
  require './metrica.rb'

	def initialize
		#@datosProyectos= Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    @datos_proyectos= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{ |h3,k3| h3[k3] = Hash.new {|h4,k4| h4[k4]=  0}} } }

    @codigo_repetido= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{|h3,k3| h3[k3]=0}}}

	end

  attr_reader :datos_proyectos,:codigo_repetido


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
      #Primera linea contiene la estructura del archivo, se omite
      fichero.gets

      #por defecto guarda saltos de carro en cada linea, de ahi el strip
      fichero.each do |linea|

        if !nombre_archivo.eql?("0-ultimoPush.txt")
          array=linea.split(',')
          if tipo_archivo.eql?("codigo-repetido.csv") 
            if !linea.eql?("\n")
              #25,103,2,
              #59,D:\prueba\proyectos\acra\src\main\java\org\acra\collector\SettingsCollector.java,
              #89,D:\prueba\proyectos\acra\src\main\java\org\acra\collector\SettingsCollector.java
            
              indice=codigo_repetido.size
              codigo_repetido[nombre_proyecto][indice][:num_lineas_codigo_repetidas]=array[0].to_i
              codigo_repetido[nombre_proyecto][indice][:num_tokens_repetidos]=array[1].to_i
              codigo_repetido[nombre_proyecto][indice][:num_ocurrencias]=array[2].to_i
              codigo_repetido[nombre_proyecto][indice][:secuencia_ocurrencias]=array.drop(3).join(" ")
            end
          else
            paquete=array[1]
            nombre_clase=array[2]

            #quitar comillas del string
            paquete.tr!('"',"")
            nombre_clase.tr!('"',"")

            mensaje=array[5]
            lista_mensaje= mensaje.scan(/\s+\d+/)

            valor_metrica=lista_mensaje.first.strip if tipo_archivo.eql?("complejidad-ciclo.csv")

            valor_metrica = lista_mensaje.last if tipo_archivo.eql?("lineas-codigo.csv")

            if tipo_archivo.eql?("complejidad-ciclo.csv")
              if !mensaje.include?("class")
                datos_proyectos[nombre_proyecto][paquete][nombre_clase][:complejidad]+=valor_metrica.to_i
              end
            end

            datos_proyectos[nombre_proyecto][paquete][nombre_clase][:loc]+=valor_metrica.to_i if tipo_archivo.eql?("lineas-codigo.csv")
          end
        end
      end
    end
  end

  def numLineasCodigoRepetidas(proyecto)
    #codigo_repetido[nombre_proyecto][indice][:num_lineas_codigo_repetidas]
    num_lineas_codigo_repetidas_totales=0
    codigo_repetido[proyecto].each{|k,v| num_lineas_codigo_repetidas_totales+= codigo_repetido[proyecto][k][:num_lineas_codigo_repetidas]}
    num_lineas_codigo_repetidas_totales
  end

  def densidadComplejidadCiclomatica(complejidad_ciclomatica_total,loc_totales)
    (complejidad_ciclomatica_total.valor.to_f/loc_totales.valor)
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
    clase[:complejidad]
  end

    def loc_por_clase(clase)
    clase[:loc]
  end

  def recorrer_archivos_directorio(dir, level=0)
    #puts "#{' '*level}#{dir}"
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

