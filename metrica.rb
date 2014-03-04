class Metrica

	def initialize(nombre, valor)
		@nombre=nombre
		@valor = valor
	end

	attr_reader :nombre, :valor

	def to_s
		"#{nombre}: #{valor}\n"
	end

end