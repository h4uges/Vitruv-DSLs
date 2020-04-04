package tools.vitruv.dsls.commonalities.generator

import com.google.inject.Inject
import org.apache.log4j.Level
import org.apache.log4j.Logger
import tools.vitruv.dsls.commonalities.language.Commonality
import tools.vitruv.dsls.commonalities.language.Participation
import tools.vitruv.dsls.reactions.builder.FluentReactionsSegmentBuilder

import static com.google.common.base.Preconditions.*

import static extension tools.vitruv.dsls.commonalities.language.extensions.CommonalitiesLanguageModelExtensions.*

/**
 * Generates the matching reaction and routines for a participation, in its own
 * specified context.
 */
package class MatchParticipationReactionsBuilder extends ReactionsSubGenerator {

	private static val Logger logger = Logger.getLogger(ReactionsGenerator) => [level = Level.TRACE]

	static class Factory extends InjectingFactoryBase {
		def createFor(Participation participation) {
			return new MatchParticipationReactionsBuilder(participation).injectMembers
		}
	}

	@Inject extension ParticipationContextHelper participationContextHelper
	@Inject ParticipationMatchingReactionsBuilder.Provider participationMatchingReactionsBuilderProvider

	// Note: May be a commonality participation.
	val Participation participation
	val Commonality commonality

	private new(Participation participation) {
		checkNotNull(participation, "participation is null")
		this.participation = participation
		this.commonality = participation.containingCommonality
	}

	// Dummy constructor for Guice
	package new() {
		this.participation = null
		this.commonality = null
		throw new IllegalStateException("Use the Factory to create instances of this class!")
	}

	def package void generateReactions(FluentReactionsSegmentBuilder segment) {
		val participationContext = participation.participationContext
		if (!participationContext.isPresent) {
			logger.debug('''Commonality «commonality»: Found no own participation context for participation «
				participation.name»''')
			return;
		}

		val extension matchingReactionsBuilder = participationMatchingReactionsBuilderProvider.getFor(segment)
		participationContext.get.generateReactions
	}
}
