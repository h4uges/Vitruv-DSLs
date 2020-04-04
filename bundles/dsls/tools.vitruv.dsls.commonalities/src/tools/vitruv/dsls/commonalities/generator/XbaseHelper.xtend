package tools.vitruv.dsls.commonalities.generator

import edu.kit.ipd.sdq.activextendannotations.Utility
import java.util.ArrayList
import java.util.Arrays
import java.util.Optional
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmIdentifiableElement
import org.eclipse.xtext.common.types.access.IJvmTypeProvider
import org.eclipse.xtext.xbase.XAbstractFeatureCall
import org.eclipse.xtext.xbase.XBlockExpression
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.XMemberFeatureCall
import org.eclipse.xtext.xbase.XbaseFactory

import static extension tools.vitruv.dsls.commonalities.generator.JvmTypeProviderHelper.*

@Utility
package class XbaseHelper {

	def static package join(XExpression first, XExpression second) {
		if (first === null) return second
		if (second === null) return first
		doJoin(first, second)
	}

	def private static dispatch XExpression doJoin(XExpression firstExpression, XBlockExpression secondBlock) {
		val secondExpressions = new ArrayList(secondBlock.expressions)
		secondBlock.expressions.clear()
		secondBlock.expressions += #[firstExpression] + secondExpressions
		secondBlock
	}

	def private static dispatch XExpression doJoin(XBlockExpression firstBlock, XBlockExpression secondBlock) {
		firstBlock.expressions += secondBlock.expressions
		firstBlock
	}

	def private static dispatch XExpression doJoin(XBlockExpression firstBlock, XExpression secondExpression) {
		firstBlock.expressions += secondExpression
		firstBlock
	}

	def private static dispatch XExpression doJoin(XExpression firstExpression, XExpression secondExpression) {
		XbaseFactory.eINSTANCE.createXBlockExpression => [
			expressions += #[firstExpression, secondExpression]
		]
	}

	// Needed to convince the Xtend type system.
	def package static expressions(XExpression... expressions) {
		Arrays.asList(expressions)
	}

	def package static stringLiteral(String string) {
		XbaseFactory.eINSTANCE.createXStringLiteral => [
			value = string
		]
	}

	def package static memberFeatureCall(XExpression target) {
		XbaseFactory.eINSTANCE.createXMemberFeatureCall => [
			memberCallTarget = target
		]
	}

	def package static memberFeatureCall(JvmIdentifiableElement targetElement) {
		targetElement.featureCall.memberFeatureCall
	}

	def package static memberFeatureCall(XExpression target, JvmIdentifiableElement featureElement) {
		target.memberFeatureCall => [
			feature = featureElement
		]
	}

	def package static memberFeatureCall(JvmIdentifiableElement targetElement, JvmIdentifiableElement featureElement) {
		targetElement.featureCall.memberFeatureCall(featureElement)
	}

	def package static set(XMemberFeatureCall target, XMemberFeatureCall source) {
		target => [
			memberCallTarget = source.memberCallTarget
			feature = source.feature
		]
	}

	def package static featureCall(JvmIdentifiableElement featureElement) {
		XbaseFactory.eINSTANCE.createXFeatureCall => [
			feature = featureElement
		]
	}

	def package static <T extends XExpression> T copy(T expression) {
		return EcoreUtil.copy(expression)
	}

	def package static noArgsConstructorCall(JvmDeclaredType type) {
		XbaseFactory.eINSTANCE.createXConstructorCall => [
			constructor = type.findNoArgsConstructor
			explicitConstructorCall = true
		]
	}

	def package static nullLiteral() {
		XbaseFactory.eINSTANCE.createXNullLiteral
	}

	def static negated(XExpression operand, IJvmTypeProvider typeProvider) {
		return XbaseFactory.eINSTANCE.createXUnaryOperation => [
			feature = typeProvider.findMethod(BooleanExtensions, 'operator_not')
			it.operand = operand
		]
	}

	def static or(XExpression leftOperand, XExpression rightOperand, IJvmTypeProvider typeProvider) {
		return XbaseFactory.eINSTANCE.createXBinaryOperation => [
			it.leftOperand = leftOperand
			feature = typeProvider.findMethod(BooleanExtensions, 'operator_or')
			it.rightOperand = rightOperand
		]
	}

	def static and(XExpression leftOperand, XExpression rightOperand, IJvmTypeProvider typeProvider) {
		return XbaseFactory.eINSTANCE.createXBinaryOperation => [
			it.leftOperand = leftOperand
			feature = typeProvider.findMethod(BooleanExtensions, 'operator_and')
			it.rightOperand = rightOperand
		]
	}

	def static equals(XExpression leftOperand, XExpression rightOperand, IJvmTypeProvider typeProvider) {
		return XbaseFactory.eINSTANCE.createXBinaryOperation => [
			it.leftOperand = leftOperand
			feature = typeProvider.findMethod(ObjectExtensions, 'operator_equals')
			it.rightOperand = rightOperand
		]
	}

	def static notEquals(XExpression leftOperand, XExpression rightOperand, IJvmTypeProvider typeProvider) {
		return XbaseFactory.eINSTANCE.createXBinaryOperation => [
			it.leftOperand = leftOperand
			feature = typeProvider.findMethod(ObjectExtensions, 'operator_notEquals')
			it.rightOperand = rightOperand
		]
	}

	def static equalsNull(XExpression leftOperand, IJvmTypeProvider typeProvider) {
		return leftOperand.equals(nullLiteral, typeProvider)
	}

	def static notEqualsNull(XExpression leftOperand, IJvmTypeProvider typeProvider) {
		return leftOperand.notEquals(nullLiteral, typeProvider)
	}

	def static optionalIsPresent(IJvmTypeProvider typeProvider, XAbstractFeatureCall optional) {
		return optional.memberFeatureCall => [
			it.implicitReceiver = null
			it.explicitOperationCall = true
			feature = typeProvider.findDeclaredType(Optional).findMethod("isPresent")
		]
	}

	def static optionalGet(IJvmTypeProvider typeProvider, XAbstractFeatureCall optional) {
		return optional.memberFeatureCall => [
			feature = typeProvider.findDeclaredType(Optional).findMethod("get")
		]
	}

	def static ifOptionalPresent(IJvmTypeProvider typeProvider, XAbstractFeatureCall optional, XExpression then) {
		return XbaseFactory.eINSTANCE.createXIfExpression => [
			it.^if = optionalIsPresent(typeProvider, optional)
			it.then = then
		]
	}
}
