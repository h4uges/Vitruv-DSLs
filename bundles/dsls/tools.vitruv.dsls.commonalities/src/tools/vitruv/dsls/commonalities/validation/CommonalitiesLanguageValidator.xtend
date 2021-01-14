/*
 * generated by Xtext 2.12.0
 */
package tools.vitruv.dsls.commonalities.validation

import java.util.HashSet
import org.eclipse.xtext.validation.Check
import tools.vitruv.dsls.commonalities.language.Commonality
import tools.vitruv.dsls.commonalities.language.CommonalityAttribute
import tools.vitruv.dsls.commonalities.language.CommonalityAttributeMapping
import tools.vitruv.dsls.commonalities.language.CommonalityAttributeOperand
import tools.vitruv.dsls.commonalities.language.CommonalityReference
import tools.vitruv.dsls.commonalities.language.CommonalityReferenceMapping
import tools.vitruv.dsls.commonalities.language.OperatorAttributeMapping
import tools.vitruv.dsls.commonalities.language.OperatorReferenceMapping
import tools.vitruv.dsls.commonalities.language.Participation
import tools.vitruv.dsls.commonalities.language.ParticipationAttributeOperand
import tools.vitruv.dsls.commonalities.language.ParticipationClass
import tools.vitruv.dsls.commonalities.language.ReferencedParticipationAttributeOperand
import tools.vitruv.dsls.commonalities.language.SimpleReferenceMapping
import tools.vitruv.dsls.commonalities.language.elements.Metaclass

import static tools.vitruv.dsls.commonalities.language.LanguagePackage.Literals.*
import static tools.vitruv.framework.util.XtendAssertHelper.*

import static extension tools.vitruv.dsls.commonalities.language.extensions.CommonalitiesLanguageModelExtensions.*
import static extension tools.vitruv.dsls.commonalities.participation.ParticipationContextHelper.*

/**
 * This class contains custom validation rules.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CommonalitiesLanguageValidator extends AbstractCommonalitiesLanguageValidator {
	// TODO Check that singleton classes are not accessed inside mappings.
	// Mappings keep specific intermediate and participation instances
	// consistent. But the singleton objects are shared by those participation
	// instances: Modifying them in reaction to changes to individual
	// intermediate instances bears the risk for issues, such as those
	// modifications overwriting each other.

	@Check
	def checkParticipationClasses(Participation participation) {
		if (participation.allClasses.isEmpty) {
			error("Participation is empty.", participation, null)
		} else if (participation.nonRootClasses.empty) {
			error("Participation has no non-root classes.", participation, null)
		}
	// TODO check for containment cycles
	}

	@Check
	def checkCommonalityFeatureNames(Commonality commonality) {
		// Check for name clashes among commonality attributes and references:
		val attributeNames = new HashSet
		for (CommonalityAttribute attribute : commonality.attributes) {
			if (!attributeNames.add(attribute.name)) {
				error('''There is already another attribute or reference with name ‹«attribute.name»›.''', attribute,
					COMMONALITY_ATTRIBUTE__NAME)
			}
		}
		for (CommonalityReference reference : commonality.references) {
			if (!attributeNames.add(reference.name)) {
				error('''There is already another attribute or reference with name ‹«reference.name»›.''', reference,
					COMMONALITY_REFERENCE__NAME)
			}
		}
	}

	@Check
	def checkCommonalityAttributeMappings(CommonalityAttribute attribute) {
		// For every participation attribute there is at most one reading
		// attribute mapping within the same commonality attribute:
		val readParticipationAttributes = new HashSet
		for (CommonalityAttributeMapping mapping : attribute.mappings.filter[isRead]) {
			val participationAttribute = mapping.participationAttribute
			if (participationAttribute !== null) {
				if (!readParticipationAttributes.add(participationAttribute)) {
					error('''There are multiple mappings which read the participation attribute '«participationAttribute»'.''',
						COMMONALITY_ATTRIBUTE__MAPPINGS)
				}
			}
		}
	}

	@Check
	def checkOperatorAttributeMapping(OperatorAttributeMapping mapping) {
		val commonalityAttributeType = mapping.commonalityAttributeType
		if (commonalityAttributeType === null) {
			val typeDescription = mapping.operator.commonalityAttributeTypeDescription
			error('''Could not find the operator’s declared commonality attribute type ‹«typeDescription.qualifiedTypeName»›.''',
				OPERATOR_ATTRIBUTE_MAPPING__OPERATOR)
		}

		val participationAttributeType = mapping.participationAttributeType
		if (participationAttributeType === null) {
			val typeDescription = mapping.operator.participationAttributeTypeDescription
			error('''Could not find the operator’s declared participation attribute type ‹«typeDescription.qualifiedTypeName»›.''',
				OPERATOR_ATTRIBUTE_MAPPING__OPERATOR)
		}

		val participationAttributeOperandsCount = mapping.participationAttributeOperands.size
		if (participationAttributeOperandsCount > 1) {
			error("There can only be at most one participation attribute operand.",
				OPERATOR_ATTRIBUTE_MAPPING__OPERANDS)
		} else if (participationAttributeOperandsCount == 0 && mapping.participationClassOperands.size == 0) {
			error('''Attribute mapping operators need to declare at least one participation attribute or participation «
				»class operand.''', OPERATOR_ATTRIBUTE_MAPPING__OPERANDS)
		}

		if (mapping.involvedParticipations.size > 1) {
			error("The mapping can only refer to participation attributes and classes of a single participation.",
				OPERATOR_ATTRIBUTE_MAPPING__OPERANDS)
		}

		val commonalityAttribute = mapping.declaringAttribute
		if (mapping.commonalityAttributeOperands.exists[it.attributeReference.attribute == commonalityAttribute]) {
			error('''The commonality attribute «commonalityAttribute.name» cannot be used as operand. It gets «
				»implicitly passed to the operator.''', OPERATOR_ATTRIBUTE_MAPPING__OPERANDS)
		}
	}

	private static def getParticipationAttributeOperands(OperatorAttributeMapping mapping) {
		return mapping.operands.filter(ParticipationAttributeOperand)
	}

	private static def getInvolvedParticipations(OperatorAttributeMapping mapping) {
		return mapping.operands.map[participation].filterNull.toSet
	}

	private static def getCommonalityAttributeOperands(OperatorAttributeMapping mapping) {
		return mapping.operands.filter(CommonalityAttributeOperand)
	}

	@Check
	def checkReferenceMapping(CommonalityReferenceMapping mapping) {
		val participation = mapping.participation
		// The participation may be null if the mapping is still incomplete. We
		// skip the validation in this case.
		if (participation === null) {
			return;
		}

		val referencedParticipations = mapping.referencedParticipations.toList
		if (referencedParticipations.size === 0) {
			error('''«mapping.referencedCommonality» has no participation of domain «participation.domainName».''',
				mapping, null)
			return;
		} else if (referencedParticipations.size > 1) {
			error('''Ambiguous reference mapping: «mapping.referencedCommonality» has more than one participation of «
				»domain «participation.domainName».''', mapping, null)
			return;
		}

		// Sub type specific checks:
		if (!checkConcreteReferenceMapping(mapping)) {
			return;
		}
	}

	private static def getReferencedParticipations(CommonalityReferenceMapping mapping) {
		val participationDomainName = mapping.participation.domainName
		val referencedCommonality = mapping.referencedCommonality
		return referencedCommonality.participations.filter [
			it.domainName == participationDomainName
		]
	}

	// Returns false in case of error.
	private def dispatch boolean checkConcreteReferenceMapping(SimpleReferenceMapping mapping) {
		val referenceRightType = mapping.reference.type
		if (!(referenceRightType instanceof Metaclass)) {
			error("Reference mappings can only use EReferences.", SIMPLE_REFERENCE_MAPPING__REFERENCE)
			return false
		}

		val referencedParticipation = mapping.referencedParticipation
		val nonRootBoundaryClasses = referencedParticipation.nonRootBoundaryClasses
		assertTrue(!nonRootBoundaryClasses.empty)
		if (!nonRootBoundaryClasses.filter[!mapping.isAssignmentCompatible(it)].empty) {
			error('''The referenced classes of participation ‹«referencedParticipation»› in «mapping.referencedCommonality» are not assignment compatible with reference type «referenceRightType».''',
				SIMPLE_REFERENCE_MAPPING__REFERENCE)
			return false
		}
		return true
	}

	// Returns false in case of error.
	private def dispatch boolean checkConcreteReferenceMapping(OperatorReferenceMapping mapping) {
		if (mapping.operator.isAttributeReference) {
			// Checks specific to attribute reference mappings:
			if (mapping.operands.filter(ReferencedParticipationAttributeOperand).empty) {
				error("No referenced participation attribute specified.", OPERATOR_REFERENCE_MAPPING__OPERANDS)
				return false
			}
			val referencedParticipation = mapping.referencedParticipation
			if (referencedParticipation.participationContext.isEmpty) {
				error("The referenced participation specifies no root context.", mapping, null)
				return false
			}
		}
		return true
	}

	@Check
	def checkParticipationClassSuperclassIsNotAbstract(ParticipationClass participationClass) {
		if (participationClass.superMetaclass !== null && participationClass.superMetaclass.isAbstract) {
			error('''Abstract classes cannot be used as participations.''', PARTICIPATION_CLASS__SUPER_METACLASS)
		}
	}

	// TODO support multiple resource root containers?
	/**
	 * Participations can only contain a single Resource class.
	 * <p>
	 * If the participation has a Resource class, it is required to be the only
	 * root container class.
	 * <p>
	 * Note: If the participation does not specify any Resource root container,
	 * it either relies on external commonality reference mappings to specify a
	 * root container for it, or it is a commonality participation whose
	 * classes are implicitly contained inside the intermediate model's root.
	 * In these cases, the participation is allowed to have multiple root
	 * classes.
	 */
	@Check
	def checkParticipationHasSingleResourceRoot(Participation participation) {
		val resourceClasses = participation.resourceClasses.toSet
		if (resourceClasses.size > 1) {
			error('''Participations can only contain a single Resource class.''', participation, null)
		} else if (resourceClasses.size == 1 && resourceClasses != participation.rootContainerClasses) {
			error('''The Resource class has to be the (only) root class.''', participation, null)
		}
	}

	private static def getResourceClasses(Participation participation) {
		return participation.allClasses.filter[isForResource]
	}

	@Check
	def checkSingleton(Participation participation) {
		val numberOfSingletons = participation.singletonClasses.size
		if (numberOfSingletons == 0) return;

		if (numberOfSingletons > 1) {
			error('''Participations can only contain a single singleton class.''', participation, null)
		} else {
			if (!participation.hasResourceClass) {
				error('''Participations with a singleton class marked need to specify a Resource root.''',
					participation, null)
			}

			// Note: The singleton class also indicates the head of the participation's root. We therefore prohibit
			// specifying that any of the other classes be contained in one of the singleton's containers.
			val singletonClass = participation.singletonClass
			val singletonContainers = singletonClass.transitiveContainerClasses
			if (singletonContainers.exists[containedClasses.size > 1]) {
				error('''The containers of the singleton class need to form a containment chain (contain each at most «
					»one object).''', participation, null)
			}
		}
	}

	private static def getSingletonClasses(Participation participation) {
		return participation.allClasses.filter[isSingleton]
	}
}
