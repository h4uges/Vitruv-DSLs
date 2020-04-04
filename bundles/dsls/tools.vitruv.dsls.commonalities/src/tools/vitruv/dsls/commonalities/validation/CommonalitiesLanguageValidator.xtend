/*
 * generated by Xtext 2.12.0
 */
package tools.vitruv.dsls.commonalities.validation

import java.util.regex.Pattern
import org.eclipse.xtext.validation.Check
import tools.vitruv.dsls.commonalities.language.Aliasable
import tools.vitruv.dsls.commonalities.language.CommonalityReferenceMapping
import tools.vitruv.dsls.commonalities.language.Participation
import tools.vitruv.dsls.commonalities.language.ParticipationClass
import tools.vitruv.dsls.commonalities.language.elements.Metaclass

import static tools.vitruv.dsls.commonalities.language.LanguagePackage.Literals.*

import static extension tools.vitruv.dsls.commonalities.language.extensions.CommonalitiesLanguageModelExtensions.*

/**
 * This class contains custom validation rules.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CommonalitiesLanguageValidator extends AbstractCommonalitiesLanguageValidator {

	// Note: This is a subset of the valid IDs
	static val ALIAS_REGEX = "^[a-zA-Z][a-zA-z0-9_]*$"
	static val ALIAS_PATTERN = Pattern.compile(ALIAS_REGEX)

	@Check
	def checkAlias(Aliasable aliasable) {
		val alias = aliasable.alias
		if (alias === null) return; // has no alias -> ignore
		if (!ALIAS_PATTERN.matcher(alias).matches) {
			error('''Invalid alias («alias»). Valid format: «ALIAS_REGEX»)''', ALIASABLE__ALIAS)
		}
	}

	@Check
	def checkCommonalityReferenceMappingHasCorrectType(CommonalityReferenceMapping mapping) {
		val referenceRightType = mapping.reference?.type
		if (referenceRightType === null) return;
		if (!(referenceRightType instanceof Metaclass)) {
			error('Reference Mappings can only use EReferences', COMMONALITY_REFERENCE_MAPPING__REFERENCE)
		} else {
			val matchingParticipations = mapping.matchingReferencedParticipations.toList
			if (matchingParticipations.size === 0) {
				error('''«mapping.referencedCommonality» has no participation with a subtype of «
				»«referenceRightType».''', COMMONALITY_REFERENCE_MAPPING__REFERENCE)
			} else if (matchingParticipations.size > 1) {
				error('''Ambiguous reference mapping: «mapping.declaringReference.referenceType» has more than one «
					»participations with a subtype of «referenceRightType».''',
					COMMONALITY_REFERENCE_MAPPING__REFERENCE)
			}
		}
	}

	@Check
	def checkParticipationClassSuperclassIsNotAbstract(ParticipationClass participationClass) {
		if (participationClass.superMetaclass?.isAbstract) {
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

	def private static getResourceClasses(Participation participation) {
		return participation.classes.filter[isForResource]
	}
}
