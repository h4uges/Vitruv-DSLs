package tools.vitruv.dsls.commonalities.generator

import com.google.inject.Inject
import java.util.Collections
import java.util.HashMap
import java.util.Map
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.xtext.common.types.TypesFactory
import org.eclipse.xtext.xbase.XbaseFactory
import tools.vitruv.dsls.commonalities.generator.ReactionsHelper.RoutineCallContext
import tools.vitruv.dsls.commonalities.language.OperatorReferenceMapping
import tools.vitruv.dsls.commonalities.language.ParticipationAttributeOperand
import tools.vitruv.dsls.commonalities.language.ReferenceMappingOperand
import tools.vitruv.dsls.commonalities.language.ReferencedParticipationAttributeOperand
import tools.vitruv.dsls.commonalities.language.extensions.OperatorContainment
import tools.vitruv.dsls.commonalities.language.extensions.ParticipationContext
import tools.vitruv.dsls.reactions.builder.FluentReactionsSegmentBuilder
import tools.vitruv.dsls.reactions.builder.FluentRoutineBuilder
import tools.vitruv.dsls.reactions.builder.FluentRoutineBuilder.RoutineCallParameter
import tools.vitruv.dsls.reactions.builder.TypeProvider

import static com.google.common.base.Preconditions.*
import static tools.vitruv.dsls.commonalities.generator.EmfAccessExpressions.*

import static extension tools.vitruv.dsls.commonalities.generator.ReactionsGeneratorConventions.*
import static extension tools.vitruv.dsls.commonalities.generator.ReactionsHelper.*
import static extension tools.vitruv.dsls.commonalities.generator.XbaseHelper.*
import static extension tools.vitruv.dsls.commonalities.language.extensions.CommonalitiesLanguageModelExtensions.*

/**
 * Invoked by the ParticipationMatchingReactionsBuilder.
 * <p>
 * Depends on some of the routines generated by the
 * ParticipationMatchingReactionsBuilder.
 */
package class AttributeReferenceMatchingReactionsBuilder extends ReactionsGenerationHelper {

	@GenerationScoped
	static class Provider extends ReactionsSegmentScopedProvider<AttributeReferenceMatchingReactionsBuilder> {

		protected override createFor(FluentReactionsSegmentBuilder segment) {
			return new AttributeReferenceMatchingReactionsBuilder(segment).injectMembers
		}

		def generateAttributeReferenceMatchingReactions(FluentReactionsSegmentBuilder segment,
			ParticipationContext participationContext) {
			getFor(segment).generateAttributeReferenceMatchingReactions(participationContext)
		}

		def getMatchAttributeReferenceElementsRoutine(FluentReactionsSegmentBuilder segment,
			ParticipationContext participationContext) {
			// Ensure that the required routines have been generated:
			getFor(segment).generateRoutines(participationContext)
			return getFor(segment).getMatchAttributeReferenceElementsRoutine(participationContext)
		}

		def getMatchAttributeReferenceContainerRoutine(FluentReactionsSegmentBuilder segment,
			ParticipationContext participationContext) {
			// Ensure that the required routines have been generated:
			getFor(segment).generateRoutines(participationContext)
			return getFor(segment).getMatchAttributeReferenceContainerRoutine(participationContext)
		}
	}

	@Inject extension ReferenceMappingOperatorHelper referenceMappingOperatorHelper
	@Inject extension AttributeChangeReactionsHelper attributeChangeReactionsHelper
	@Inject extension IntermediateContainmentReactionsHelper intermediateContainmentReactionsHelper
	@Inject extension InsertIntermediateRoutineBuilder.Provider insertIntermediateRoutineBuilderProvider

	val FluentReactionsSegmentBuilder segment

	val Map<ParticipationContext, FluentRoutineBuilder> checkAttributeReferenceRoutines = new HashMap
	val Map<ParticipationContext, FluentRoutineBuilder> checkAttributeReferenceElementsRemovedRoutines = new HashMap
	val Map<ParticipationContext, FluentRoutineBuilder> checkAttributeReferenceElementRemovedRoutines = new HashMap
	val Map<ParticipationContext, FluentRoutineBuilder> matchAttributeReferenceElementsRoutines = new HashMap
	val Map<ParticipationContext, FluentRoutineBuilder> matchAttributeReferenceContainerRoutines = new HashMap

	private new(FluentReactionsSegmentBuilder segment) {
		checkNotNull(segment, "segment is null")
		this.segment = segment
	}

	// Dummy constructor for Guice
	package new() {
		this.segment = null
		throw new IllegalStateException("Use the Provider to get instances of this class!")
	}

	def package void generateAttributeReferenceMatchingReactions(ParticipationContext participationContext) {
		if (!participationContext.isForAttributeReferenceMapping) return;

		participationContext.generateRoutines()

		participationContext.attributeReferenceContainments.forEach [ extension contextContainment |
			val containment = containment
			// assert: containment.operator.isAttributeReference
			segment += participationContext.reactionsForAttributeReferenceChange(containment)
		]
	}

	def private generateRoutines(ParticipationContext participationContext) {
		// assert: participationContext.isForAttributeReferenceMapping
		// assert: participationContext.isRootContext
		segment += participationContext.checkAttributeReferenceRoutine
		segment += participationContext.checkAttributeReferenceElementsRemovedRoutine
		segment += participationContext.checkAttributeReferenceElementRemovedRoutine
		segment += participationContext.matchAttributeReferenceElementsRoutine
		segment += participationContext.matchAttributeReferenceContainerRoutine
	}

	def private reactionsForAttributeReferenceChange(ParticipationContext participationContext,
		OperatorContainment containment) {
		// assert: participationContext.isForAttributeReferenceMapping
		return containment.operands.flatMap [
			participationContext.reactionsForAttributeReferenceChange(containment, it)
		]
	}

	// In reaction to an attribute change inside the referencing participation:
	def private dispatch reactionsForAttributeReferenceChange(ParticipationContext participationContext,
		OperatorContainment containment, ParticipationAttributeOperand operand) {
		val attribute = operand.participationAttribute
		val reactionNameSuffix = participationContext.reactionNameSuffix
		return attribute.getAttributeChangeReactions(reactionNameSuffix) [ changeType , it |
			// Check if any of the previous attribute references got removed:
			call(participationContext.checkAttributeReferenceElementsRemovedRoutine,
				new RoutineCallParameter[affectedEObject])

			// Check if there are new attribute references:
			call(participationContext.matchAttributeReferenceElementsRoutine,
				new RoutineCallParameter[affectedEObject])
		]
	}

	// In reaction to an attribute change inside the referenced participation:
	def private dispatch reactionsForAttributeReferenceChange(ParticipationContext participationContext,
		OperatorContainment containment, ReferencedParticipationAttributeOperand operand) {
		val attribute = operand.participationAttribute
		val reactionNameSuffix = participationContext.reactionNameSuffix + "_element"
		return attribute.getAttributeChangeReactions(reactionNameSuffix) [ changeType , it |
			// Check if any previous attribute reference is no longer fulfilled:
			call(participationContext.checkAttributeReferenceElementRemovedRoutine,
				new RoutineCallParameter[affectedEObject])

			// Check if there is a new attribute reference container:
			call(participationContext.matchAttributeReferenceContainerRoutine,
				new RoutineCallParameter[affectedEObject])
		]
	}

	def private dispatch reactionsForAttributeReferenceChange(ParticipationContext participationContext,
		OperatorContainment containment, ReferenceMappingOperand operand) {
		return Collections.emptyList // for any other type of operand (eg. literal operands)
	}

	/**
	 * Checks if any attribute references for the given container participation object are no longer fulfilled.
	 */
	private def getCheckAttributeReferenceElementsRemovedRoutine(ParticipationContext participationContext) {
		return checkAttributeReferenceElementsRemovedRoutines.computeIfAbsent(participationContext) [
			// assert: participationContext.isForAttributeReferenceMapping
			val commonalityReference = participationContext.referenceMapping.declaringReference
			val referencingCommonality = participationContext.referencingCommonality
			val referencedCommonality = participationContext.referencedCommonality

			val extension routineCallContext = new RoutineCallContext
			create.routine('''checkAttributeReferenceElementsRemoved«participationContext.reactionNameSuffix»''')
				.input [
					// Some object of the referencing participation (not necessarily the attribute reference root):
					model(EcorePackage.Literals.EOBJECT, PARTICIPATION_OBJECT)
				].match [
					vall(REFERENCING_INTERMEDIATE).retrieve(referencingCommonality.changeClass)
						.correspondingTo(PARTICIPATION_OBJECT)
				].action [
					execute [extension typeProvider |
						val extension jvmTypeReferenceBuilder = jvmTypeReferenceBuilder
						XbaseFactory.eINSTANCE.createXBlockExpression => [
							if (commonalityReference.isMultiValued) {
								// Get all referenced intermediates:
								val referencedIntermediatesVar = XbaseFactory.eINSTANCE.createXVariableDeclaration => [
									name = REFERENCED_INTERMEDIATES
									type = typeRef(Iterable, typeRef(referencedCommonality.changeClass.javaClassName))
									writeable = false
									right = getListFeatureValue(typeProvider, variable(REFERENCING_INTERMEDIATE),
										commonalityReference.correspondingEReference)
								]
								expressions += referencedIntermediatesVar

								// For each referenced intermediate, check if the attribute reference still holds:
								val referencedIntermediateVar = TypesFactory.eINSTANCE.createJvmFormalParameter => [
									parameterType = typeRef(referencedCommonality.changeClass.javaClassName)
									name = REFERENCED_INTERMEDIATE
								]
								expressions += XbaseFactory.eINSTANCE.createXForLoopExpression => [
									declaredParam = referencedIntermediateVar
									forExpression = referencedIntermediatesVar.featureCall
									eachExpression = XbaseFactory.eINSTANCE.createXBlockExpression => [
										expressions += routineCallContext.createRoutineCall(typeProvider,
											participationContext.checkAttributeReferenceRoutine,
											variable(REFERENCING_INTERMEDIATE), referencedIntermediateVar.featureCall)
									]
								]
							} else {
								// Get the referenced intermediate:
								val referencedIntermediateVar = XbaseFactory.eINSTANCE.createXVariableDeclaration => [
									name = REFERENCED_INTERMEDIATE
									type = typeRef(referencedCommonality.changeClass.javaClassName)
									writeable = false
									right = getFeatureValue(typeProvider, variable(REFERENCING_INTERMEDIATE),
										commonalityReference.correspondingEReference)
								]
								expressions += referencedIntermediateVar

								// Check if the attribute reference still holds:
								expressions += routineCallContext.createRoutineCall(typeProvider,
									participationContext.checkAttributeReferenceRoutine,
									variable(REFERENCING_INTERMEDIATE), referencedIntermediateVar.featureCall)
							}
						]
					].setCallerContext
				].setCaller
		]
	}

	/**
	 * Checks if any attribute reference for the given contained participation object is no longer fulfilled.
	 */
	private def getCheckAttributeReferenceElementRemovedRoutine(ParticipationContext participationContext) {
		return checkAttributeReferenceElementRemovedRoutines.computeIfAbsent(participationContext) [
			// assert: participationContext.isForAttributeReferenceMapping
			val commonalityReference = participationContext.referenceMapping.declaringReference
			val referencedCommonality = participationContext.referencedCommonality

			val extension routineCallContext = new RoutineCallContext
			create.routine('''checkAttributeReferenceElementRemoved«participationContext.reactionNameSuffix»''')
				.input [
					model(EcorePackage.Literals.EOBJECT, PARTICIPATION_OBJECT)
				].match [
					vall(REFERENCED_INTERMEDIATE).retrieve(referencedCommonality.changeClass)
						.correspondingTo(PARTICIPATION_OBJECT)
				].action [
					execute [extension typeProvider |
						XbaseFactory.eINSTANCE.createXBlockExpression => [
							// Get the container intermediate, if there is one for the specific commonality reference:
							val referencingIntermediateVar = XbaseFactory.eINSTANCE.createXVariableDeclaration => [
								name = REFERENCING_INTERMEDIATE
								writeable = false
								right = getIntermediateContainer(typeProvider, variable(REFERENCED_INTERMEDIATE),
									commonalityReference)
							]
							expressions += referencingIntermediateVar

							// If the container intermediate is not null:
							expressions += XbaseFactory.eINSTANCE.createXIfExpression => [
								^if = referencingIntermediateVar.featureCall.notEqualsNull(typeProvider)
								// Then check if the attribute reference still holds:
								then = routineCallContext.createRoutineCall(typeProvider,
									participationContext.checkAttributeReferenceRoutine,
									referencingIntermediateVar.featureCall, variable(REFERENCED_INTERMEDIATE))
							]
						]
					].setCallerContext
				].setCaller
		]
	}

	// Checks for new attribute references for a given container participation object:
	private def getMatchAttributeReferenceElementsRoutine(ParticipationContext participationContext) {
		return matchAttributeReferenceElementsRoutines.computeIfAbsent(participationContext) [
			// assert: participationContext.isForAttributeReferenceMapping
			val mapping = participationContext.referenceMapping as OperatorReferenceMapping
			val referencingCommonality = participationContext.referencingCommonality
			val referencedCommonality = participationContext.referencedCommonality
			val attributeReferenceRoot = participationContext.attributeReferenceRoot
			val attributeReferenceRootClass = attributeReferenceRoot.participationClass

			val extension routineCallContext = new RoutineCallContext
			create.routine('''matchAttributeReferenceElements«participationContext.reactionNameSuffix»''')
				.input [
					// Some object of the referencing participation (not necessarily the attribute reference root):
					model(EcorePackage.Literals.EOBJECT, PARTICIPATION_OBJECT)
				].match [
					vall(REFERENCING_INTERMEDIATE).retrieve(referencingCommonality.changeClass)
						.correspondingTo(PARTICIPATION_OBJECT)
					vall(REFERENCE_ROOT).retrieveAsserted(attributeReferenceRootClass.changeClass)
						.correspondingTo(REFERENCING_INTERMEDIATE)
						.taggedWith(attributeReferenceRootClass.correspondenceTag)
				].action [
					execute [extension typeProvider |
						val extension jvmTypeReferenceBuilder = jvmTypeReferenceBuilder
						XbaseFactory.eINSTANCE.createXBlockExpression => [
							// Query the operator for all potentially contained intermediates:
							val operator = mapping.operator
							val operands = mapping.operands
							val referencedIntermediatesVar = XbaseFactory.eINSTANCE.createXVariableDeclaration => [
								name = REFERENCED_INTERMEDIATES
								type = typeRef(Iterable, typeRef(referencedCommonality.changeClass.javaClassName))
								writeable = false
								right = operator.callGetPotentiallyContainedIntermediates(operands,
									variable(REFERENCE_ROOT), referencedCommonality.changeClass, typeProvider)
							]
							expressions += referencedIntermediatesVar

							// For each potentially referenced intermediate, check if the attribute reference is
							// fulfilled:
							val referencedIntermediateVar = TypesFactory.eINSTANCE.createJvmFormalParameter => [
								parameterType = typeRef(referencedCommonality.changeClass.javaClassName)
								name = REFERENCED_INTERMEDIATE
							]
							expressions += XbaseFactory.eINSTANCE.createXForLoopExpression => [
								declaredParam = referencedIntermediateVar
								forExpression = referencedIntermediatesVar.featureCall
								eachExpression = XbaseFactory.eINSTANCE.createXBlockExpression => [
									expressions += routineCallContext.createRoutineCall(typeProvider,
										participationContext.checkAttributeReferenceRoutine,
										variable(REFERENCING_INTERMEDIATE), referencedIntermediateVar.featureCall)
								]
							]
						]
					].setCallerContext
				].setCaller
		]
	}

	// Checks for a new attribute reference container for a given potentially contained participation object:
	private def getMatchAttributeReferenceContainerRoutine(ParticipationContext participationContext) {
		return matchAttributeReferenceContainerRoutines.computeIfAbsent(participationContext) [
			// assert: participationContext.isForAttributeReferenceMapping
			val mapping = participationContext.referenceMapping as OperatorReferenceMapping
			val referencingCommonality = participationContext.referencingCommonality
			val referencedCommonality = participationContext.referencedCommonality

			val extension routineCallContext = new RoutineCallContext
			create.routine('''matchAttributeReferenceContainer«participationContext.reactionNameSuffix»''')
				.input [
					// Some object of the potentially referenced participation:
					model(EcorePackage.Literals.EOBJECT, PARTICIPATION_OBJECT)
				].match [
					vall(REFERENCED_INTERMEDIATE).retrieve(referencedCommonality.changeClass)
						.correspondingTo(PARTICIPATION_OBJECT)
				].action [
					execute [extension typeProvider |
						val extension jvmTypeReferenceBuilder = jvmTypeReferenceBuilder
						XbaseFactory.eINSTANCE.createXBlockExpression => [
							// Query the operator for the potential container intermediate:
							val operator = mapping.operator
							val operands = mapping.operands
							val referencingIntermediateVar = XbaseFactory.eINSTANCE.createXVariableDeclaration => [
								name = REFERENCING_INTERMEDIATE
								type = typeRef(referencingCommonality.changeClass.javaClassName)
								writeable = false
								right = operator.callGetPotentialContainerIntermediate(operands,
									variable(PARTICIPATION_OBJECT), referencingCommonality.changeClass, typeProvider)
							]
							expressions += referencingIntermediateVar

							// If the candidate container intermediate is not null:
							expressions += XbaseFactory.eINSTANCE.createXIfExpression => [
								^if = referencingIntermediateVar.featureCall.notEqualsNull(typeProvider)
								// Then check if the attribute reference is fulfilled:
								then = routineCallContext.createRoutineCall(typeProvider,
									participationContext.checkAttributeReferenceRoutine,
									referencingIntermediateVar.featureCall, variable(REFERENCED_INTERMEDIATE))
							]
						]
					].setCallerContext
				].setCaller
		]
	}

	/**
	 * Checks if the participation corresponding to the given 'referenced
	 * intermediate' is, according to the attribute reference operator,
	 * contained by the participation corresponding to the given 'referencing
	 * intermediate'.
	 * <p>
	 * If the attribute reference is fulfilled, but the referenced intermediate
	 * is not actually referenced yet, we insert it into the respective
	 * reference of the referencing intermediate.
	 * <p>
	 * If the attribute reference is not fulfilled, but the referenced
	 * intermediate is currently referenced by the referencing intermediate, we
	 * move it into the intermediate model root.
	 */
	private def getCheckAttributeReferenceRoutine(ParticipationContext participationContext) {
		return checkAttributeReferenceRoutines.computeIfAbsent(participationContext) [
			// assert: participationContext.isForAttributeReferenceMapping
			val commonalityReference = participationContext.referenceMapping.declaringReference
			val referencingCommonality = participationContext.referencingCommonality
			val referencedCommonality = participationContext.referencedCommonality
			val attributeReferenceRoot = participationContext.attributeReferenceRoot
			val attributeReferenceRootClass = attributeReferenceRoot.participationClass

			val extension routineCallContext = new RoutineCallContext
			create.routine('''checkAttributeReference«participationContext.reactionNameSuffix»''')
				.input [
					model(referencingCommonality.changeClass, REFERENCING_INTERMEDIATE)
					model(referencedCommonality.changeClass, REFERENCED_INTERMEDIATE)
				].match [
					vall(REFERENCE_ROOT).retrieveAsserted(attributeReferenceRootClass.changeClass)
						.correspondingTo(REFERENCING_INTERMEDIATE)
						.taggedWith(attributeReferenceRootClass.correspondenceTag)

					// assert: !participationContext.attributeReferenceContainments.empty
					participationContext.attributeReferenceContainments.forEach [ extension contextContainment |
						// assert: !contained.isExternal (no conflicts between variable names expected)
						val containedClass = contained.participationClass
						vall(containedClass.correspondingVariableName)
							.retrieveAsserted(containedClass.changeClass)
							.correspondingTo(REFERENCED_INTERMEDIATE)
							.taggedWith(containedClass.correspondenceTag)
					]
				].action [
					execute [extension typeProvider |
						XbaseFactory.eINSTANCE.createXBlockExpression => [
							// Check each attribute reference containment:
							participationContext.attributeReferenceContainments.forEach [ extension contextContainment |
								join(checkAttributeReferenceContainment(participationContext, containment,
									routineCallContext, typeProvider))
							]

							// If we did not return yet, it means that all attribute reference containments are
							// fulfilled.
							// If the referenced intermediate is not yet contained by the referencing intermediate:
							expressions += XbaseFactory.eINSTANCE.createXIfExpression => [
								^if = negated(isIntermediateContainerMatching(typeProvider,
									variable(REFERENCED_INTERMEDIATE), variable(REFERENCING_INTERMEDIATE),
									commonalityReference), typeProvider)
								// Then insert it into the referencing intermediate:
								val commonalityEReference = commonalityReference.correspondingEReference
								then = insertFeatureValue(typeProvider, variable(REFERENCING_INTERMEDIATE),
									commonalityEReference, variable(REFERENCED_INTERMEDIATE))
							]
						]
					].setCallerContext
				].setCaller
		]
	}

	/**
	 * Checks if the given attribute reference containment is fulfilled.
	 * <p>
	 * If it is not, but the referenced intermediate is currently contained by the referencing intermediate, we move it
	 * into the root of its intermediate model.
	 */
	private def checkAttributeReferenceContainment(ParticipationContext participationContext,
		OperatorContainment containment, extension RoutineCallContext routineCallContext,
		extension TypeProvider typeProvider) {
		val commonalityReference = participationContext.referenceMapping.declaringReference
		val referencedCommonality = participationContext.referencedCommonality

		val operator = containment.operator
		val operands = containment.operands
		val containedClass = containment.contained

		return XbaseFactory.eINSTANCE.createXBlockExpression => [
			// If, according to the attribute reference operator, the reference root object no longer contains the
			// referenced object:
			expressions += XbaseFactory.eINSTANCE.createXIfExpression => [
				^if = negated(operator.callIsContained(operands, variable(REFERENCE_ROOT),
					variable(containedClass.correspondingVariableName), typeProvider), typeProvider)
				then = XbaseFactory.eINSTANCE.createXBlockExpression => [
					// But if the referencing intermediate still contains the referenced intermediate:
					expressions += XbaseFactory.eINSTANCE.createXIfExpression => [
						^if = isIntermediateContainerMatching(typeProvider, variable(REFERENCED_INTERMEDIATE),
							variable(REFERENCING_INTERMEDIATE), commonalityReference)
						// Then move the referenced intermediate to the intermediate model root:
						then = routineCallContext.createRoutineCall(typeProvider,
							segment.getInsertIntermediateRoutine(referencedCommonality),
							variable(REFERENCED_INTERMEDIATE))
					]
					// In either case: Return from the routine.
					expressions += XbaseFactory.eINSTANCE.createXReturnExpression
				]
			]
		]
	}
}
