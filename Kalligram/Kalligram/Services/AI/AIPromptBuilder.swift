import Foundation

enum AIPromptBuilder {
    static func rewritePrompt(text: String, tone: AITone, goal: String?, count: Int) -> (system: String, user: String) {
        let system = """
        You are a professional writing editor. Your task is to rewrite text while preserving the core meaning.
        \(tone.promptModifier)
        Return exactly \(count) alternative versions, each separated by the delimiter "---OPTION---".
        Do not include any other text, explanations, or numbering.
        """
        var user = "Rewrite the following text:\n\n\(text)"
        if let goal {
            user += "\n\nGoal: \(goal)"
        }
        return (system, user)
    }

    static func generatePrompt(prompt: String, tone: AITone, audience: String?, lengthWords: Int?, citationContext: String?) -> (system: String, user: String) {
        var system = """
        You are a professional writer. Generate high-quality content based on the user's prompt.
        \(tone.promptModifier)
        """
        if let audience {
            system += "\nTarget audience: \(audience)"
        }
        if let lengthWords {
            system += "\nTarget length: approximately \(lengthWords) words."
        }
        if let citationContext {
            system += "\nInclude relevant citations where appropriate. Context:\n\(citationContext)"
        }
        system += "\nReturn only the generated text, no explanations or meta-commentary."
        return (system, prompt)
    }

    static func expandCondensePrompt(text: String, direction: LengthDirection, factor: Double) -> (system: String, user: String) {
        let system: String
        switch direction {
        case .expand:
            system = """
            You are a professional writer. Expand the following text to approximately \(Int(factor * 100))% of its current length.
            Add detail, examples, and elaboration while maintaining the original tone and style.
            Return only the expanded text.
            """
        case .condense:
            system = """
            You are a professional editor. Condense the following text to approximately \(Int(factor * 100))% of its current length.
            Preserve all key information while removing redundancy and tightening the prose.
            Return only the condensed text.
            """
        }
        return (system, text)
    }

    static func researchPrompt(query: String, context: String?) -> (system: String, user: String) {
        var system = """
        You are a research assistant. Provide a factual, well-sourced summary for the given research question.
        Structure your response as:
        1. A clear summary paragraph
        2. Key sources (format each as: TITLE | AUTHORS | URL | DATE | RELIABILITY_SCORE)
        3. Related questions worth exploring

        Separate sections with "---SECTION---"
        Separate sources with "---SOURCE---"
        """
        if let context {
            system += "\nDocument context for relevance:\n\(context)"
        }
        return (system, query)
    }
}
