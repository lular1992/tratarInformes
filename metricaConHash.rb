class MetricaConHash < Metrica
	
	def to_s
    	"#{nombre}:\n#{valorAstring} \n\n" 
  	end

  	def valorAstring
    	string=""
    	valor.each {|k,v| string << "#{k}: #{valor[k]} \n"}
    	string
  	end

  	def mostrarClases(clases)
    	string=""
    	clases.each{|k,v| string << "Clase #{k} \n #{mostrarMetricas(clases[k])}"}
    	string
  	end

  	def mostrarMetricas(metricas)
      
  	end



end