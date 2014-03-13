class ManipulacionFicheros

  #Ejecutar como ruby  -E UTF-8 tratarFicheros.rb

  require './proyecto.rb'
  require './metrica.rb'
  require 'yaml'


	def initialize
		#@datosProyectos= Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    @datos_generales_proyectos=Array.new
    @datos_tamanio= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{ |h3,k3| h3[k3] = Hash.new {|h4,k4| h4[k4]= Hash.new{|h5,k5| h5[k5]=0}}}}}
    @datos_resto_metricas= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{ |h3,k3| h3[k3] = Hash.new {|h4,k4| h4[k4]=Hash.new{|h5,k5| h5[k5]=Array.new}}}}}
    @codigo_repetido= Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]= Hash.new{|h3,k3| h3[k3]=0}}}

	end

  attr_reader :datos_tamanio,:datos_resto_metricas,:codigo_repetido, :datos_generales_proyectos


  def obtenerClavesProyectos(objeto_a_serializar)
    claves=Array.new
    objeto_a_serializar.each{|k,v| claves << k}
    claves
  end
  def serializarDatosProyectos(ruta_archivo,objeto_a_serializar)
    File.open(ruta_archivo, 'w') { |f| f.puts objeto_a_serializar.to_yaml }
  end

  def serializarDatosProyectosMarshall(ruta_archivo,objeto_a_serializar)
    File.open(ruta_archivo,'wb') do |f|
      f.write Marshal.dump(objeto_a_serializar)
    end
  end

  def deserializarDatosProyectosMarshall(ruta_archivo)
    lista_proyectos=Marshal.load(File.binread(ruta_archivo))
    lista_proyectos
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
        datos_generales_proyectos << proyecto
      end

      lista_proyectos
    end
  end


  def tratar_fichero(ruta_archivo,f)
    # Ficheros del formato nombreProyecto_informe_complejidad-ciclo.csv o nombreProyecto_informe_lineas-codigo.csv
    nombre_archivo= (File.basename(ruta_archivo))

    if !nombre_archivo.eql?("0-ultimoPush.txt")
      nombre_arch_array= nombre_archivo.split("_informe_")
      nombre_proyecto=nombre_arch_array.first
      tipo_archivo=nombre_arch_array.last

      #revisar nombres iguales

    end


    File.open(ruta_archivo) do|fichero|
      contador_linea=1 #borrar
      @indice_constructor=1

      fichero.gets

      fichero.gets if tipo_archivo.eql?("coupling.csv")

      fichero.each do |linea|
      #array_lineas_fichero=fichero.to_a #peta para archivos grandes

      #Primeras lineas que contienen la estructura del archivo, se omiten
      #array_lineas_fichero=array_lineas_fichero.drop(1)

      #array_lineas_fichero=array_lineas_fichero.drop(1) if tipo_archivo.eql?("coupling.csv") 

      #array_lineas_fichero.each do |linea|
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
                  #mirar si sigue siendo la misma clase
                  @clase_anterior||=nombre_clase.split("\\").last.split(".java").first 
                  @clase=nombre_clase.split("\\").last.split(".java").first 
                  metodo=mensaje.split("'").drop(1).first

                  #ver si la linea es un constructor
                  constructor=mensaje.scan(/The constructor\s\S+/).first

                  if constructor!=nil
                    @indice_constructor=1 if @clase_anterior!=@clase
                    metodo=constructor.split("'").drop(1).first << @indice_constructor.to_s
                    @indice_constructor+=1
                    @clase_anterior=@clase
                  end

                  #Primero se pasa el loc. Si no hay loc de ese metodo, no incluir la cc
                  if @datos_tamanio[nombre_proyecto][paquete][nombre_clase][metodo].keys.include?(:loc)
                    f.puts @datos_tamanio[nombre_proyecto][paquete][nombre_clase][metodo].keys
                    f.puts "entro guardar cc"
                    @datos_tamanio[nombre_proyecto][paquete][nombre_clase][metodo][:complejidad]=valor_metrica.to_i
                  end

                end

              when "lineas-codigo.csv"
                regla=array[7].tr!('"',"").strip
                valor_metrica = lista_mensaje.last
                if regla.eql?("NcssConstructorCount")
                  tipo_constructor=mensaje.scan(/The constructor with \d+/).first
                  num_params=tipo_constructor.scan(/\d+/).first
                  clase=nombre_clase.split("\\").last
                  metodo=clase.split(".java").first << num_params
                else
                  metodo=mensaje.split.drop(2).first.split("()").first
                end
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
        f.puts "linea #{contador_linea} tratada"
        contador_linea+=1
      end
      f.puts "fichero #{ruta_archivo} tratado"
    end
  end


  def numOcurrencias(proyecto,metrica,lista_reglas,f)
    hash_ocurrencias_design= Hash.new { |hash, key| hash[key] = 0 }
    lista_reglas.each do |regla|
      num_ocurrencias_regla=0
      proyecto.each do |k,v| 
      #f.puts "Paquete #{k}"
        num_ocurrencias_regla+=numOcurrenciasPaquete(proyecto[k],metrica,regla,f)
      end
      hash_ocurrencias_design[regla]=num_ocurrencias_regla
    end

    hash_ocurrencias_design
  end

  def numOcurrenciasPaquete(paquete,metrica,regla,f)
    num_ocurrencias_regla_paquete=0
    paquete.each do |k,v| 
      #f.puts "Clase #{k}" if paquete[k].keys.include?(metrica)
      num_ocurrencias_regla_paquete+=numOcurrenciasClase(paquete[k],metrica,regla,f,k) if paquete[k].keys.include?(metrica)
    end
    num_ocurrencias_regla_paquete
  end

  def numOcurrenciasClase(clase,metrica,regla,f,c)
    num_ocurrencias_regla_clase=0
    clase.each do |k,v|
             if !clase[metrica][regla].empty?
              f.puts "Clase #{c}" 
      f.puts "metrica #{metrica}"
      f.puts "Regla: #{regla}"
      #f.puts clase[metrica].keys
       #     f.puts clase[metrica].keys.include?(regla)

      f.puts "Array #{clase[metrica][regla]}"
      f.puts "numero ocurrencias #{num_ocurrencias_regla_clase}"
      f.puts "sumar #{clase[metrica][regla].size}"
    end
       num_ocurrencias_regla_clase +=clase[metrica][regla].size if clase[metrica].keys.include?(regla)
    end
    num_ocurrencias_regla_clase
  end

  def numLineasCodigoRepetidas(proyecto)
    num_lineas_codigo_repetidas_totales=0
    codigo_repetido[proyecto].each{|k,v| num_lineas_codigo_repetidas_totales+= codigo_repetido[proyecto][k][:num_lineas_codigo_repetidas]}
    num_lineas_codigo_repetidas_totales
  end

  def densidadComplejidadCiclomatica(complejidad_ciclomatica_total,loc_totales)
    (complejidad_ciclomatica_total!=0 && loc_totales !=0) ? (complejidad_ciclomatica_total.to_f/loc_totales) : 0
  end

  def complejidadCiclomaticaDelProyecto(proyecto)
    complejidad_ciclomatica_total=0
    proyecto.each {|k,v| complejidad_ciclomatica_total+=complejidad_ciclomatica_por_paquete(proyecto[k])}
    complejidad_ciclomatica_total
  end

  def complejidad_ciclomatica_por_paquete(paquete)
    complejidad_ciclomatica_paquete=0
    paquete.each {|k,v| complejidad_ciclomatica_paquete+=complejidad_ciclomatica_por_clase(paquete[k])} 
    complejidad_ciclomatica_paquete
  end

  def complejidad_ciclomatica_por_clase(clase)
    complejidad_clase=0
    clase.each {|k,v| complejidad_clase+= clase[k][:complejidad] if clase[k].keys.include?(:complejidad)}
    complejidad_clase
  end

  def locDelProyecto(proyecto)
    loc_totales=0
    proyecto.each {|k,v| loc_totales+=loc_por_paquete(proyecto[k])}
    loc_totales
  end

  def loc_por_paquete(paquete)
    loc_paquete=0
    paquete.each {|k,v| loc_paquete+=loc_por_clase(paquete[k])}
    loc_paquete
  end



  def loc_por_clase(clase)
    loc_clase=0
    clase.each{|k,v| loc_clase+=clase[k][:loc] if clase[k].keys.include?(:loc)} 
    loc_clase
  end

  def recorrer_archivos_directorio(dir, level=0,f)
    Dir["#{dir}/*"].each do |nombreArchivo|
      if !File.directory?(nombreArchivo) then
         tratar_fichero(nombreArchivo,f)
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

