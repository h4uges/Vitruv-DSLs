/*
 * generated by Xtext 2.9.0
 */
package tools.vitruv.dsls.reactions.ui.outline

import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode
import tools.vitruv.dsls.reactions.reactionsLanguage.Trigger
import tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage
import org.eclipse.xtext.ui.editor.outline.impl.EStructuralFeatureNode
import tools.vitruv.dsls.mirbase.mirBase.MetamodelImport
import tools.vitruv.dsls.mirbase.mirBase.MirBasePackage
import tools.vitruv.dsls.reactions.reactionsLanguage.Routine
import tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsFile
import tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsSegment
import tools.vitruv.dsls.reactions.reactionsLanguage.Reaction
import tools.vitruv.dsls.reactions.reactionsLanguage.Action
import tools.vitruv.dsls.reactions.reactionsLanguage.ConcreteModelChange
import static extension tools.vitruv.dsls.reactions.codegen.changetyperepresentation.ChangeTypeRepresentationExtractor.*
import static extension tools.vitruv.dsls.reactions.util.ReactionsLanguageUtil.*
import tools.vitruv.dsls.reactions.reactionsLanguage.Matcher
import tools.vitruv.dsls.reactions.reactionsLanguage.RoutineInput
import tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsImport

/**
 * Outline structure definition for a reactions file.
 *
 * @author Heiko Klare
 */
class ReactionsLanguageOutlineTreeProvider extends DefaultOutlineTreeProvider {
	protected def void _createChildren(DocumentRootNode root, ReactionsFile reactionsFile) {
		val importsNode = createEStructuralFeatureNode(root, reactionsFile, 
			MirBasePackage.Literals.MIR_BASE_FILE__METAMODEL_IMPORTS,
			imageDispatcher.invoke(reactionsFile), "imports", false);
		for (imp : reactionsFile.metamodelImports) {
			createChildren(importsNode, imp);
		}
		for (reactionsSegment : reactionsFile.reactionsSegments) {
			createChildren(root, reactionsSegment);
		}
	}
	
	protected def void _createChildren(DocumentRootNode parentNode, ReactionsSegment reactionsSegment) {
		val segmentNode = createEObjectNode(parentNode, reactionsSegment);
		val reactionsImportsNode = createEStructuralFeatureNode(segmentNode, reactionsSegment,
			ReactionsLanguagePackage.Literals.REACTIONS_SEGMENT__REACTIONS_IMPORTS, imageDispatcher.invoke(reactionsSegment),
			"reactionsImports", false);
		for (reactionsImport : reactionsSegment.reactionsImports) {
			createChildren(reactionsImportsNode, reactionsImport);
		}
		val reactionsNode = createEStructuralFeatureNode(segmentNode, reactionsSegment, 
			ReactionsLanguagePackage.Literals.REACTIONS_SEGMENT__REACTIONS, imageDispatcher.invoke(reactionsSegment), "reactions", false)
		for (reaction : reactionsSegment.reactions) {
			createChildren(reactionsNode, reaction);	
		}
		val routinesNode = createEStructuralFeatureNode(segmentNode, reactionsSegment, ReactionsLanguagePackage.Literals.REACTIONS_SEGMENT__ROUTINES, imageDispatcher.invoke(reactionsSegment), "routines", false)
		for (routine : reactionsSegment.routines) {
			createChildren(routinesNode, routine);	
		}
	}
	
	protected def void _createChildren(EStructuralFeatureNode parentNode, MetamodelImport imp) {
		val importNode = createEObjectNode(parentNode, imp);
		createEStructuralFeatureNode(importNode,
			imp, MirBasePackage.Literals.METAMODEL_IMPORT__PACKAGE,
			imageDispatcher.invoke(imp.package),
			imp.package.name, true);
	}
	
	protected def void _createChildren(EStructuralFeatureNode parentNode, ReactionsImport reactionsImport) {
		val importNode = createEObjectNode(parentNode, reactionsImport);
		createEStructuralFeatureNode(importNode, reactionsImport,
			ReactionsLanguagePackage.Literals.REACTIONS_IMPORT__IMPORTED_REACTIONS_SEGMENT,
			imageDispatcher.invoke(reactionsImport.importedReactionsSegment),
			reactionsImport.importedReactionsSegment.name, true);
	}
	
	protected def void _createChildren(EStructuralFeatureNode parentNode, Reaction reaction) {
		val reactionNode = createEObjectNode(parentNode, reaction);
		if (reaction.documentation !== null) {
			createEStructuralFeatureNode(reactionNode, reaction,
				ReactionsLanguagePackage.Literals.REACTION__DOCUMENTATION,
				imageDispatcher.invoke(reaction.documentation),
				"documentation", true);
		}
		if (reaction.trigger !== null) {
			createChildren(reactionNode, reaction.trigger);
		}
	}
	
	protected def void _createChildren(EStructuralFeatureNode parentNode, Routine routine) {
		createEObjectNode(parentNode, routine);
	}
	
	protected def void _createChildren(EStructuralFeatureNode parentNode, Trigger trigger) {
		createEObjectNode(parentNode, trigger);
	}
	
	protected def Object _text(MetamodelImport imp) {
		return imp?.name;
	}
	
	protected def Object _text(ReactionsImport reactionsImport) {
		return reactionsImport.importedReactionsSegment.name;
	}
	
	protected def Object _text(Reaction reaction) {
		return "reaction: " + reaction.formattedReactionName;
	}
	
	protected def Object _text(Routine routine) {
		return "routine: " + routine.formattedRoutineName;
	}
	
	protected def Object _text(RoutineInput routineInput) {
		return "parameters";
	}
	
	protected def Object _text(Matcher matcher) {
		return "matcher";
	}
	
	protected def Object _text(Action action) {
		return "action";
	}
	
	protected def Object _text(ReactionsSegment reactionsSegment) {
		return "segment: " + reactionsSegment.name;
	}
	
	protected def Object _text(Trigger trigger) {
		return "There is no outline for this trigger";
	}
	
	protected def Object _text(ConcreteModelChange event) {
		return '''«FOR change : event.extractChangeSequenceRepresentation.atomicChanges SEPARATOR ", "»«change.name»«ENDFOR»''';
	}
	
	protected def boolean _isLeaf(Trigger element) {
		return true;
	}
	
	protected def boolean _isLeaf(Matcher element) {
		return true;
	}
	
	protected def boolean _isLeaf(Action element) {
		return true;
	}
	
}
