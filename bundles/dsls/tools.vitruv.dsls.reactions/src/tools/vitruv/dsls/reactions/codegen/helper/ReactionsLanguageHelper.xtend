package tools.vitruv.dsls.reactions.codegen.helper

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.xbase.XExpression
import tools.vitruv.dsls.reactions.environment.SimpleTextXBlockExpression
import org.eclipse.xtext.xbase.XBlockExpression
import tools.vitruv.framework.util.datatypes.Pair;
import tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsSegment
import tools.vitruv.dsls.reactions.reactionsLanguage.Reaction
import tools.vitruv.dsls.mirbase.mirBase.MetaclassReference

final class ReactionsLanguageHelper {
	private new() {}
	
	public static def dispatch String getXBlockExpressionText(XExpression expression) '''
		{
			«NodeModelUtils.getNode(expression).text»
		}'''
	
	public static def dispatch String getXBlockExpressionText(XBlockExpression expression) {
		NodeModelUtils.getNode(expression).text;
	}
	
	public static def dispatch String getXBlockExpressionText(SimpleTextXBlockExpression blockExpression) {
		blockExpression.text.toString;
	}
	
	public static def Class<?> getJavaClass(EClass element) {
		return element.instanceClass;
	}
	
	public static def Class<?> getJavaClass(MetaclassReference metaclassReference) {
		return metaclassReference.metaclass.javaClass;
	}
	
	static def Pair<EPackage, EPackage> getSourceTargetPair(ReactionsSegment reactionsSegment) {
		val sourcePackage = reactionsSegment.fromMetamodel.model.package.topPackage;
		val targetPackage = reactionsSegment.toMetamodel.model.package.topPackage;
		if (sourcePackage != null && targetPackage != null) {
			return new Pair<EPackage, EPackage>(sourcePackage, targetPackage);
		} else {
			return null;
		}		
	}
	
	static def Pair<EPackage, EPackage> getSourceTargetPair(Reaction reaction) {
		return reaction.reactionsSegment.sourceTargetPair;
	}
	
	private static def EPackage getTopPackage(EPackage pckg) {
		return if (pckg?.nsURI != null) {
			var topPckg = pckg;
			while (topPckg.ESuperPackage != null) {
				topPckg = pckg.ESuperPackage;
			}
			return topPckg;
		} else {
			null;
		}
	}
	
}
