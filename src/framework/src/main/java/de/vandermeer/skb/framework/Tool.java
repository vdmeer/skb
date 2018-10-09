/* Copyright 2018 Sven van der Meer <vdmeer.sven@mykolab.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package de.vandermeer.skb.framework;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import de.vandermeer.asciiparagraph.AP_Context;
import de.vandermeer.asciiparagraph.AsciiParagraph;
import de.vandermeer.skb.interfaces.transformers.textformat.TextAlignment;

/**
 * Tool that takes text and creates formatted text.
 *
 * @author     Sven van der Meer &lt;vdmeer.sven@mykolab.com&gt;
 * @version    v0.0.0-SNAPSHOT build 170420 (20-Apr-17) for Java 1.8
 * @since      v0.0.0
 */
public class Tool {

	/** The paragraph context with all settings. */
	public static AP_Context CONTEXT_L1 = new AP_Context()
			.setWidth(74)
			.setAlignment(TextAlignment.JUSTIFIED_LEFT)
			.setTextLeftMargin(4)
	;

	/** The paragraph context with all settings. */
	public static AP_Context CONTEXT_L2 = new AP_Context()
			.setWidth(70)
			.setAlignment(TextAlignment.JUSTIFIED_LEFT)
			.setTextLeftMargin(8)
	;


	/**
	 * Public main to start the tool.
	 * @param args command line arguments
	 */
	public static void main(String[] args) {
		Tool execs = new Tool();
		int ret = execs.execute(args);
		System.exit(ret);
	}

	/**
	 * Creates a new ExecS object.
	 */
	public Tool(){
	}

	/**
	 * Execute function, creates text from files in arguments
	 * @param args the CLI arguments from the tool
	 * @return 0 on success, other integer on error
	 */
	public int execute(String[] args) {
		if(args.length!=2) {
			this.printHelp();
			System.exit(1);
		}

		File file = new File(args[0]);
		if(!file.exists()) {
			System.err.println("sf: file " + args[0] + " does not exist");
			System.err.println(2);
		}
		if(!file.canRead()) {
			System.err.println("sf: file " + args[0] + " not readable");
			System.err.println(3);
		}

		AP_Context ctxt = null;
		switch (args[1]) {
			case "l1":
			ctxt = CONTEXT_L1;
			break;
			case "l2":
				ctxt = CONTEXT_L2;
				break;
			default:
				System.err.println("sf: unknown paragraph context: " + args[1]);
				System.err.println(3);
				break;
		}

		String text = new String();
		try {
			BufferedReader br = new BufferedReader(new FileReader(file));
			String line;
			while ((line = br.readLine()) != null) {
				if(line.equals("+")) {
					printText(text, ctxt);
					text = new String();
				}
				else {
					text += line + "\n";
				}
			}
			br.close();
		}
		catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		printText(text, ctxt);

		return 0;
	}

	/**
	 * Print text.
	 * @param text the text to print as paragraph
	 * @param ctxt the context for the paragraph
	 */
	public void printText(String text, AP_Context ctxt) {
		AsciiParagraph ap = new AsciiParagraph(ctxt);
		ap.addText(text);
		System.out.println(ap.render());
	}

	/**
	 * Print a simple help text.
	 */
	public void printHelp() {
		System.out.println("SKB Framework");
		System.out.println("-h | --help for help");
		System.out.println("otherwise: <inputfile> <context: l1|l2>");
	}
}
