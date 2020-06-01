package tools.vitruv.dsls.commonalities.language.extensions

import edu.kit.ipd.sdq.activextendannotations.Utility
import org.eclipse.xtext.common.types.JvmDeclaredType
import tools.vitruv.dsls.commonalities.language.AttributeMappingOperator

import static extension tools.vitruv.dsls.commonalities.util.JvmAnnotationHelper.*

@Utility
package class AttributeMappingOperatorExtension {

	static val ANNOTATION = tools.vitruv.extensions.dslruntime.commonalities.operators.mapping.attribute.AttributeMappingOperator
	static val ANNOTATION_NAME = ANNOTATION.name

	def private static getAttributeMappingOperatorAnnotation(JvmDeclaredType operatorType) {
		return operatorType.annotations
			.filter[annotation.qualifiedName == ANNOTATION_NAME]
			.head
	}

	def static getAttributeMappingOperatorName(JvmDeclaredType operatorType) {
		val annotation = operatorType.attributeMappingOperatorAnnotation
		if (annotation === null) return null
		return annotation.getStringAnnotationValue('name')
	}

	def static getName(AttributeMappingOperator operator) {
		return operator.jvmType.attributeMappingOperatorName
	}

	private def static AttributeTypeDescription getAttributeTypeDescription(AttributeMappingOperator operator,
		String valueName) {
		val annotation = operator.jvmType.attributeMappingOperatorAnnotation
		if (annotation === null) return null
		val typeAnnotation = annotation.getAnnotationAnnotationValue(valueName)
		val multiValued = typeAnnotation.getBooleanAnnotationValue('multiValued')
		val typeRef = typeAnnotation.getTypeAnnotationValue('type')
		return new AttributeTypeDescription(multiValued, typeRef.qualifiedName)
	}

	def static AttributeTypeDescription getCommonalityAttributeTypeDescription(AttributeMappingOperator operator) {
		return operator.getAttributeTypeDescription('commonalityAttributeType')
	}

	def static AttributeTypeDescription getParticipationAttributeTypeDescription(AttributeMappingOperator operator) {
		return operator.getAttributeTypeDescription('participationAttributeType')
	}
}
