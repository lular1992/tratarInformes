class Comentarios < Metrica

	def to_s
		"#{nombre}: #{mPaquetes}\n"
	end


  	def mPaquetes
    	string=""
    	valor.each {|k,v| string << "Paquete #{k} \n #{mClases(valor[k])}"}
    	string
  	end

  	def mClases(clases)
    	string=""
    	clases.each{|k,v| string << "Clase #{k} \n #{mMetricas(clases[k])}"}
    	string
  	end

  	def mMetricas(metricas)
    	"Comment size mayor de 6 en lineas: #{metricas["CommentSize"]} \n Comment required en lineas: #{metricas["CommentRequired"]} \n Comment content en lineas: #{metricas["CommentContent"]} \n\n-------\n\n"
 	end

end