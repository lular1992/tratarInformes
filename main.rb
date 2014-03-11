require './proyecto.rb'
require './metrica.rb'
require './tratarFicheros.rb'
require './comentarios.rb'
require './metricaConHash.rb'


manipular= ManipulacionFicheros.new
reglas_design=["UseUtilityClass","SwitchDensity","AvoidDeeplyNestedIfStmts","AbstractClassWithoutAbstractMethod","TooFewBranchesForASwitchStatement","CompareObjectsWithEquals","TooFewBranchesForASwitchStatement"]
reglas_comentarios=["CommentSize","CommentRequired","CommentContent"]
reglas_coupling=["CouplingBetweenObjects","ExcessiveImports","LooseCoupling","LawOfDemeter"]
reglas_empty_code=["EmptyCatchBlock","EmptyIfStmt","EmptyWhileStmt","EmptyTryBlock","EmptyFinallyBlock","EmptySwitchStatements","EmptySynchronizedBlock","EmptyStatementNotInLoop","EmptyInitializer","EmptyStatementBlock","EmptyStaticInitializer"]
reglas_unused_code=["UnusedPrivateField","UnusedLocalVariable","UnusedPrivateMethod","UnusedFormalParameter","UnusedModifier"]
reglas_junit=["JUnitStaticSuite","JUnitSpelling","JUnitAssertionsShouldIncludeMessage","JUnitTestsShouldIncludeAssert","TestClassWithoutTestCases","UnnecessaryBooleanAssertion","UseAssertEqualsInsteadOfAssertTrue","UseAssertSameInsteadOfAssertTrue","UseAssertNullInsteadOfAssertTrue","SimplifyBooleanAssertion","JUnitTestContainsTooManyAsserts","UseAssertTrueInsteadOfAssertEquals"]

lista_proyectos=manipular.cargarDatosGeneralesProyectos('F:/prueba/informes/tratar/0-ultimoPush.txt')

  #File.open('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/debug.txt','w') do |f|
	manipular.recorrer_archivos_directorio('F:/prueba/informes/tratar')
    #f.puts manipular.datos_tamanio
  #end
  #File.open('F:/prueba/debug.txt','w') do |f|
   # f.puts manipular.datos_resto_metricas
 #end

 manipular.serializarDatosProyectos('F:/prueba/datos_generales_proyectos.yaml',manipular.datos_generales_proyectos)
 manipular.serializarDatosProyectos('F:/prueba/datos_tamanio.yaml',manipular.datos_tamanio)
manipular.serializarDatosProyectos('F:/prueba/datos_resto_metricas.yaml',manipular.datos_resto_metricas)
manipular.serializarDatosProyectos('F:/prueba/codigo_repetido.yaml',manipular.codigo_repetido)

=begin
hash_proyectos=manipular.datos_tamanio

File.open('F:/prueba/debug.txt','w') do |f|
lista_proyectos.each do |proyecto|
  complejidad_ciclomatica= Metrica.new("Complejidad ciclomatica total",manipular.complejidadCiclomaticaDelProyecto(hash_proyectos[proyecto.nombre]))
  loc=Metrica.new("Lineas de codigo totales",manipular.locDelProyecto(hash_proyectos[proyecto.nombre]))
  densidad_complejidad= Metrica.new("Densidad complejidad ciclomatica",manipular.densidadComplejidadCiclomatica(complejidad_ciclomatica.valor,loc.valor))
  lineas_codigo_repetidas= Metrica.new("Lineas codigo repetido",manipular.numLineasCodigoRepetidas(proyecto.nombre))
  comentarios= MetricaConHash.new("Comentarios",manipular.numOcurrencias(manipular.datos_resto_metricas[proyecto.nombre],:comentarios,reglas_comentarios,f))
  f.puts "\n\nDESIIIIIGN \n\n"
  #design= MetricaConHash.new("Design",manipular.numOcurrencias(manipular.datos_resto_metricas[proyecto.nombre],:design,reglas_design,f))
  coupling= MetricaConHash.new("Coupling",manipular.numOcurrencias(manipular.datos_resto_metricas[proyecto.nombre],:coupling,reglas_coupling,f))
  empty_code= MetricaConHash.new("Empty code",manipular.numOcurrencias(manipular.datos_resto_metricas[proyecto.nombre],:empty_code,reglas_empty_code,f))
  unused_code= MetricaConHash.new("Unused code",manipular.numOcurrencias(manipular.datos_resto_metricas[proyecto.nombre],:unused_code,reglas_unused_code,f))
  junit= MetricaConHash.new("Junit",manipular.numOcurrencias(manipular.datos_resto_metricas[proyecto.nombre],:junit,reglas_junit,f))

  proyecto.metricas[:complejidad_ciclomatica]=complejidad_ciclomatica
  proyecto.metricas[:loc]=loc
  proyecto.metricas[:densidad_complejidad]=densidad_complejidad
  proyecto.metricas[:lineas_codigo_repetidas]=lineas_codigo_repetidas
  proyecto.metricas[:comentarios]=comentarios
  #proyecto.metricas[:design]=design
  proyecto.metricas[:coupling]=coupling
  proyecto.metricas[:empty_code]=empty_code
  proyecto.metricas[:unused_code]=unused_code
  proyecto.metricas[:junit]=junit

end
end


File.open('F:/prueba/debug.txt','w') do |f|

#lista_proyectos.each do |proyecto|
  f.puts manipular.datos_resto_metricas
  f.puts "\n\n\n"
  #design= MetricaConHash.new("Design",manipular.numOcurrencias(manipular.datos_resto_metricas[proyecto.nombre],:design,reglas_design,f))
  #proyecto.metricas[:design]=design

  #end
end

#Si uno no tiene valor de densidad, peta la comparacion
#lista_proyectos.sort! { |proyecto1,proyecto2| proyecto2.metricas[:densidad_complejidad].valor <=> proyecto1.metricas[:densidad_complejidad].valor}

manipular.guardarEnFichero('F:/prueba/proyectos.txt',lista_proyectos)






=begin
manipular.serializarDatosProyectos('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/datos-proyectos-guardados.yaml',manipular.datos_tamanio)

manipular.deserializarDatosProyectos('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/datos-proyectos-guardados.yaml',"datos_tamanio")

=begin
  File.open('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/datos-proyectos2.txt','w') do |f|
    f.puts manipular.datos_tamanio #.mostrarDatosProyecto
  end

=end
#manipular.guardarEnFormatoCsv('C:/Users/Ana/Desktop/tratarInformesRevisar/tratar/datos-proyectos.csv',lista_proyectos)
