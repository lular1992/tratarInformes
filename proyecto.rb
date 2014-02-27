class Proyecto

	def initialize (nombre,url,version,complejidad_ciclomatica,loc,densidad_complejidad)
		@nombre=nombre
		@url=url
		@version=version
		@complejidad_ciclomatica=complejidad_ciclomatica
		@loc=loc
		@densidad_complejidad=densidad_complejidad
	end

	attr_reader :nombre, :url, :version, :complejidad_ciclomatica, :loc, :densidad_complejidad

	def to_s
		"Proyecto #{nombre} \n Url: #{url} \n Version: #{version} \n Complejidad ciclomatica total: #{complejidad_ciclomatica} \n Lineas de codigo totales: #{loc} \n Densidad de la complejidad ciclomatica: #{densidad_complejidad}\n\n"
	end
end