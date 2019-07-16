package tools.vitruv.dsls.mappings.generator

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.resource.XtextResourceSet
import tools.vitruv.dsls.mappings.generator.integration.IReactionIntegrationGenerator
import tools.vitruv.dsls.mappings.generator.integration.StandaloneReactionIntegrationGenerator
import tools.vitruv.dsls.mappings.mappingsLanguage.MappingsFile
import tools.vitruv.dsls.mappings.mappingsLanguage.MappingsSegment
import tools.vitruv.dsls.reactions.api.generator.IReactionsGenerator
import tools.vitruv.dsls.reactions.builder.FluentReactionsLanguageBuilder
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.xbase.util.XExpressionHelper
import tools.vitruv.dsls.mappings.generator.integration.EmbeddedReactionIntegrationGenerator

//import tools.vitruv.dsls.reactions.builder.FluentReactionsLanguageBuilder
class MappingsLanguageGenerator implements IGenerator2 {
	@Inject FluentReactionsLanguageBuilder create
	@Inject Provider<IReactionsGenerator> reactionsGeneratorProvider
	@Inject Provider<XtextResourceSet> resourceSetProvider
	IReactionIntegrationGenerator reactionIntegrationGenerator

	override afterGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
//		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override beforeGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
//		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		reactionIntegrationGenerator = new EmbeddedReactionIntegrationGenerator
		val reactionsGenerator = reactionsGeneratorProvider.get
		val resourceSet = resourceSetProvider.get
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE)
		XExpressionParser.initParser(resourceSet)
		val mappingsFiles = input?.contents?.filter(MappingsFile)
		for (mappingsFile : mappingsFiles) {
			reactionsGenerator.useResourceSet(mappingsFile.eResource.resourceSet)
			val segments = mappingsFile.mappingsSegments
			val mappingsPackage = mappingsFile.eResource.URI.trimSegments(1) + ".mappings"
			for (segment : segments) {
				val l2rContext = generateReactions(mappingsPackage, mappingsFile, segment, reactionsGenerator, true);
				val r2lContext = generateReactions(mappingsPackage, mappingsFile, segment, reactionsGenerator, false);
				reactionIntegrationGenerator.init(l2rContext, r2lContext)
				checkIntegrations(segment)
				reactionsGenerator.attachReactionsFile(l2rContext)
				reactionsGenerator.attachReactionsFile(r2lContext)
			}
		}
		reactionIntegrationGenerator.generate(fsa, reactionsGenerator)
		reactionsGenerator.generate(fsa)
		reactionsGenerator.writeReactions(fsa)
	}
	
	private def attachReactionsFile(IReactionsGenerator generator, ReactionGeneratorContext context){
		val file = context.file
		//add all imports from mappingsfile to reactionfile
	    context.mappingsFile.metamodelImports.forEach[
	    	file.importMetamodel(it)
	    ]
		generator.addReactionsFile(file)			
	}

	private def generateReactions(String mappingsPackage, MappingsFile mappingsFile, MappingsSegment segment,
		IReactionsGenerator reactionsGenerator, boolean l2r) {
		val basePackageForSegment = mappingsPackage + "." + segment.name
		val reactionsFileGenerator = new MappingsReactionsFileGenerator(basePackageForSegment, segment, l2r,
			reactionsGenerator, create, mappingsFile);
		var reactionsContext = reactionsFileGenerator.createAndInitializeReactionsFile()
		val generator = new MappingReactionsGenerator(basePackageForSegment, segment, l2r, reactionsGenerator, create)
		generator.generateReactionsAndRoutines(reactionsContext)
		reactionsContext
	}

	private def checkIntegrations(MappingsSegment segment) {
		for (mapping : segment.mappings) {
			reactionIntegrationGenerator.check(mapping)
		}
	}
}
