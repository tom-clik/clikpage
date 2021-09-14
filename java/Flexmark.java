import com.vladsch.flexmark.ext.abbreviation.AbbreviationExtension;
import com.vladsch.flexmark.ext.admonition.AdmonitionExtension;
import com.vladsch.flexmark.ext.anchorlink.AnchorLinkExtension;
import com.vladsch.flexmark.ext.attributes.AttributesExtension;
import com.vladsch.flexmark.ext.autolink.AutolinkExtension;
import com.vladsch.flexmark.ext.definition.DefinitionExtension;
import com.vladsch.flexmark.ext.emoji.EmojiExtension;
import com.vladsch.flexmark.ext.escaped.character.EscapedCharacterExtension;
import com.vladsch.flexmark.ext.footnotes.FootnoteExtension;
import com.vladsch.flexmark.ext.gfm.strikethrough.StrikethroughExtension;
import com.vladsch.flexmark.ext.tables.TablesExtension;
import com.vladsch.flexmark.html.HtmlRenderer;
import com.vladsch.flexmark.parser.Parser;
import com.vladsch.flexmark.util.ast.Node;
import com.vladsch.flexmark.util.data.MutableDataSet;
import com.vladsch.flexmark.util.misc.Extension;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class Flexmark {

	MutableDataSet options = new MutableDataSet();
	Parser parser;
	HtmlRenderer renderer;

	public Flexmark() {
		this("all");
	}

	public Flexmark(String options) {
		boolean all = options.equals("all");
		Set<String> optionsSet = new HashSet<String>(Arrays.asList(options.split(", ")));
		ArrayList<Extension> extensions = new ArrayList<>();

		if (all || optionsSet.contains("tables")) {
			extensions.add(TablesExtension.create());
		}
		if (all || optionsSet.contains("abbreviation")) {
			extensions.add(AbbreviationExtension.create());
		}
		if (all || optionsSet.contains("admonition")) {
			extensions.add(AdmonitionExtension.create());
		}	
		if (all || optionsSet.contains("anchorlink")) {
			extensions.add(AnchorLinkExtension.create());
		}
		if (all || optionsSet.contains("attributes")) {
			extensions.add(AttributesExtension.create());
		}
		if (all || optionsSet.contains("autolink")) {
			extensions.add(AutolinkExtension.create());
		}
		if (all || optionsSet.contains("definition")) {
			extensions.add(DefinitionExtension.create());
		}
		if (all || optionsSet.contains("emoji")) {
			extensions.add(EmojiExtension.create());
		}
		if (all || optionsSet.contains("escapedcharacter")) {
			extensions.add(EscapedCharacterExtension.create());
		}
		if (all || optionsSet.contains("footnote")) {
			extensions.add(FootnoteExtension.create());
		}
		if (all || optionsSet.contains("strikethrough")) {
			extensions.add(StrikethroughExtension.create());
		}
		
		this.options.set(Parser.EXTENSIONS,extensions);
		
		if (optionsSet.contains("softbreaks")) {
			this.options.set(HtmlRenderer.SOFT_BREAK, "<br />\n");
		}
		
		parser = Parser.builder(this.options).build();
		renderer = HtmlRenderer.builder(this.options).build();

	}

	public String render(String s) {

		// You can re-use parser and renderer instances
		Node document = parser.parse(s);
		String html = renderer.render(document); 
		return html;
	}
}