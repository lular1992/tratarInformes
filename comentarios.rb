class Comentarios < Metrica
	
	def to_s
    	"#{nombre}: #{mostrarPaquetes}\n"
  	end

  	def mostrarPaquetes
    	string=""
    	valor.each {|k,v| string << "Paquete #{k} \n #{mostrarClases(valor[k])}"}
    	string
  	end

  	def mostrarClases(clases)
    	string=""
    	clases.each{|k,v| string << "Clase #{k} \n #{mostrarMetricas(clases[k])}"}
    	string
  	end

  	def mostrarMetricas(metricas)
      	"Comment size mayor de 6 en lineas: #{metricas[:comentarios]["CommentSize"]} \n Comment required en lineas: #{metricas[:comentarios]["CommentRequired"]} \n Comment content en lineas: #{metricas[:comentarios]["CommentContent"]} \n\n-------\n\n"
  	end

end