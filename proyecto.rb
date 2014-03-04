class Proyecto

	require './metrica.rb'

	def initialize (nombre,descripcion,url,homepage,language,owner,pushed_at,
		created_at, forks, open_issues, watchers, size, tiene_descargas, 
		tiene_wiki,metricas=Hash.new)

		@nombre=nombre
		@descripcion = descripcion
		@url=url
		@homepage = homepage
		@language=language
		@owner=owner
		@pushed_at=pushed_at
		@created_at= created_at
		@forks= forks
		@open_issues= open_issues
		@watchers = watchers
		@size =size
		@tiene_descargas=tiene_descargas
		@tiene_wiki=tiene_wiki

		@metricas=metricas
	end

	attr_reader :nombre, :descripcion, :url, :homepage, :language, :owner, :pushed_at, :created_at, :forks, :open_issues, :watchers, :size, :tiene_descargas, :tiene_wiki,:metricas
	attr_writer :metricas
	def to_s
		s= "Proyecto #{nombre} \n Descripcion: #{descripcion} Url: #{url} \n " <<
		"Homepage: #{homepage} \n Lenguaje: #{language} \n Owner: #{owner} \n Version: #{pushed_at} \n " <<
		"Creado el: #{created_at} \n Forks: #{forks} \n Open issues: #{open_issues} \n Watchers: #{watchers} \n " <<
		"Size: #{size} \n Tiene descargas: #{tiene_descargas} \n Tiene wiki: #{tiene_wiki} \n "

		s << "---- Metricas: ----#{hashAString(metricas)}\n" if metricas!=nil

		s << "---------------------------------------------------------------------"

		s
	end

	def hashAString(hash)
		string="\n"
		hash.each{|k,v| string<<hash[k].to_s}
		string
	end

end