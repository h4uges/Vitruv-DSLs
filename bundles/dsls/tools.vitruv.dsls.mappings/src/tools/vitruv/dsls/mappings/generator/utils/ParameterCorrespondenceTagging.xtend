package tools.vitruv.dsls.mappings.generator.utils

import tools.vitruv.dsls.mappings.generator.ReactionGeneratorContext
import tools.vitruv.dsls.mappings.mappingsLanguage.MappingParameter
import tools.vitruv.dsls.mirbase.mirBase.NamedMetaclassReference

class ParameterCorrespondenceTagging {

	private static ReactionGeneratorContext context

	public static def setContext(ReactionGeneratorContext context) {
		ParameterCorrespondenceTagging.context = context
	}

	public static def String getCorrespondenceTag(MappingParameter reactionParameter,
		MappingParameter correspondingParameter) {
		if (!context.left2right) {
			return createCorrespondenceTag(correspondingParameter.value, reactionParameter.value)
		}
		createCorrespondenceTag(reactionParameter.value, correspondingParameter.value)
	}

	private static def String createCorrespondenceTag(NamedMetaclassReference reactionParameter,
		NamedMetaclassReference correspondingParameter) '''
	«createMappingContext»_correspondence_«reactionParameter.createParameter»_with_«correspondingParameter.createParameter»'''

	private static def String createParameter(NamedMetaclassReference parameter) '''
	«parameter.metaclass.name»:«parameter.name»'''

	private static def String createMappingContext() '''
	«context.segment.name»_map_«context.segment.leftDomain.domain»_and_«context.segment.rightDomain.domain»'''
}
