package tools.vitruv.dsls.commonalities.generator

import java.util.HashMap
import java.util.Map
import javax.inject.Inject
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.xbase.XFeatureCall
import org.eclipse.xtext.xbase.XbaseFactory
import tools.vitruv.dsls.commonalities.language.Commonality
import tools.vitruv.dsls.commonalities.language.Participation
import tools.vitruv.dsls.commonalities.language.ParticipationClass
import tools.vitruv.dsls.commonalities.language.elements.NamedElement
import tools.vitruv.dsls.commonalities.language.elements.ResourceMetaclass
import tools.vitruv.dsls.reactions.builder.FluentReactionsLanguageBuilder
import tools.vitruv.dsls.reactions.builder.FluentRoutineBuilder
import tools.vitruv.dsls.reactions.builder.FluentRoutineBuilder.RoutineTypeProvider
import tools.vitruv.extensions.dslruntime.commonalities.IntermediateModelManagement
import tools.vitruv.extensions.dslruntime.commonalities.resources.IntermediateResourceBridge
import tools.vitruv.extensions.dslruntime.commonalities.resources.ResourcesPackage

import static extension edu.kit.ipd.sdq.commons.util.java.lang.IterableUtil.*
import static extension tools.vitruv.dsls.commonalities.generator.JvmTypeProviderHelper.*
import static extension tools.vitruv.dsls.commonalities.generator.ReactionsGeneratorConventions.*
import static extension tools.vitruv.dsls.commonalities.generator.XbaseHelper.*
import static extension tools.vitruv.dsls.commonalities.language.extensions.CommonalitiesLanguageModelExtensions.*

package class ReactionsGenerationContext {

	@Accessors(PACKAGE_GETTER)
	var extension GenerationContext generationContext
	@Accessors(PACKAGE_GETTER)
	@Inject FluentReactionsLanguageBuilder create

	val Map<Participation, FluentRoutineBuilder> intermediateResourcePrepareRoutineCache = new HashMap
	// Since a commonality may have other commonalities as participations, commonality insert routines can potentially
	// be found for all pairs of a commonality and its participations.
	val Map<Pair<NamedElement, NamedElement>, FluentRoutineBuilder> commonalityInsertRoutineCache = new HashMap

	def package wrappingContext(GenerationContext generationContext) {
		this.generationContext = generationContext
		return this
	}

	def private getInsertRoutine(NamedElement fromParticipationOrCommonality, Commonality toCommonality) {
		commonalityInsertRoutineCache.computeIfAbsent(Pair.of(fromParticipationOrCommonality, toCommonality), [ 
			create.routine('''intermediateInsert_«toCommonality.name»''')
				.input [model(EcorePackage.eINSTANCE.EObject, newValue)]
				.match [
					vall('intermediate').retrieveAsserted(toCommonality.changeClass).correspondingTo.newValue
				].action [
					execute [insertIntermediate(variable('intermediate'), toCommonality)]
				]
		])
	}

	def package getInsertRoutine(Participation fromParticipation, Commonality toCommonality) {
		getInsertRoutine(fromParticipation as NamedElement, toCommonality)
	}

	def package getInsertRoutine(Commonality fromCommonality, Commonality toCommonality) {
		getInsertRoutine(fromCommonality as NamedElement, toCommonality)
	}

	def package getIntermediateResourceBridgeRoutine(ParticipationClass participationClass) {
		intermediateResourcePrepareRoutineCache.computeIfAbsent(participationClass.participation, [ participation |
			if (participation.hasResourceParticipation) {
				create.routine('''rootInsertIntermediateResoureBridge''')
					.input [model(EcorePackage.eINSTANCE.EObject, newValue)]
					.match [
						vall('contentIntermediate').retrieve(commonalityFile.changeClass).correspondingTo.newValue
					]
					.action [
						vall('resourceBridge').create(ResourcesPackage.eINSTANCE.intermediateResourceBridge).andInitialize [
							initIntermediateResourceBridge(variable('resourceBridge'), newValue)
						]
						execute [insertResourceBridge(variable('resourceBridge'), variable('contentIntermediate'))]
						addCorrespondenceBetween('resourceBridge').and('contentIntermediate')
							.taggedWith(participation.resourceParticipation.correspondenceTag)
				]
			}
		])
	}

	def private initIntermediateResourceBridge(extension RoutineTypeProvider typeProvider, XFeatureCall resourceBridge,
		XFeatureCall modelElement) {
		XbaseFactory.eINSTANCE.createXBlockExpression => [
			expressions += expressions(
				XbaseFactory.eINSTANCE.createXAssignment => [
					assignable = resourceBridge.newFeatureCall
					feature = typeProvider.findMethod(IntermediateResourceBridge, 'setCorrespondenceModel')
					value = XbaseFactory.eINSTANCE.createXFeatureCall => [
						feature = routineUserExecutionType.findAttribute('correspondenceModel')
						implicitReceiver = routineUserExecution
					]
				],
				XbaseFactory.eINSTANCE.createXAssignment => [
					assignable = resourceBridge.newFeatureCall
					feature = typeProvider.findMethod(IntermediateResourceBridge, 'setResourceAccess')
					value = XbaseFactory.eINSTANCE.createXFeatureCall => [
						feature = routineUserExecutionType.findAttribute('resourceAccess')
						implicitReceiver = routineUserExecution
					]
				],
				XbaseFactory.eINSTANCE.createXMemberFeatureCall => [
					memberCallTarget = resourceBridge.newFeatureCall
					feature = typeProvider.findMethod(IntermediateResourceBridge, 'initialiseForModelElement')
					explicitOperationCall = true
					memberCallArguments += modelElement
				]
			)
		]
	}

	def private insertResourceBridge(extension RoutineTypeProvider typeProvider, XFeatureCall resourceBridge,
		XFeatureCall intermediate) {
		val resourceVariableDeclaration = XbaseFactory.eINSTANCE.createXVariableDeclaration => [
			name = 'intermediateModelResource'
			right = createMetadataResource(typeProvider, commonality)
		]
		XbaseFactory.eINSTANCE.createXBlockExpression => [
			expressions += expressions(
				resourceVariableDeclaration,
				XbaseFactory.eINSTANCE.createXMemberFeatureCall => [
					memberCallTarget = XbaseFactory.eINSTANCE.createXFeatureCall => [
						feature = resourceVariableDeclaration
					]
					feature = typeProvider.findMethod(IntermediateModelManagement, 'addResourceBridge').
						staticExtensionWildcardImported
					memberCallArguments += #[resourceBridge, intermediate]
					explicitOperationCall = true
				]
			)
		]
	}

	def private insertIntermediate(extension RoutineTypeProvider typeProvider, XFeatureCall intermediate,
		Commonality commonality) {
		val resourceVariableDeclaration = XbaseFactory.eINSTANCE.createXVariableDeclaration => [
			name = 'intermediateModelResource'
			right = createMetadataResource(typeProvider, commonality)
		]
		XbaseFactory.eINSTANCE.createXBlockExpression => [
			expressions += expressions(
				resourceVariableDeclaration,
				XbaseFactory.eINSTANCE.createXMemberFeatureCall => [
					memberCallTarget = XbaseFactory.eINSTANCE.createXFeatureCall => [
						feature = resourceVariableDeclaration
					]
					feature = typeProvider.findMethod(IntermediateModelManagement, 'addIntermediate').
						staticExtensionWildcardImported
					memberCallArguments += intermediate
					explicitOperationCall = true
				]
			)
		]
	}

	def private createMetadataResource(extension RoutineTypeProvider typeProvider, Commonality commonality) {
		XbaseFactory.eINSTANCE.createXFeatureCall => [
			implicitReceiver = routineUserExecution
			feature = routineUserExecutionType.findMethod('getMetadataResource')
			// this string is intentionally hardcoded into the reactions
			// and not computed by a runtime class, as this allows to
			// change the way the identifier is computed without breaking
			// existing intermediate models
			featureCallArguments += expressions(
				XbaseFactory.eINSTANCE.createXStringLiteral => [
					value = 'commonalities'
				],
				XbaseFactory.eINSTANCE.createXStringLiteral => [
					value = commonality.concept.name
				],
				XbaseFactory.eINSTANCE.createXStringLiteral => [
					value = commonality.name + '.intermediate'
				]
			)
			explicitOperationCall = true
		]
	}

	def package hasResourceParticipation(Participation participation) {
		participation.classes.containsAny[isForResource]
	}

	def package getResourceParticipation(Participation participation) {
		participation.classes.findFirst[isForResource]
	}

	def package isForResource(ParticipationClass participationClass) {
		participationClass.superMetaclass instanceof ResourceMetaclass
	}
}
