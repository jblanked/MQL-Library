//+------------------------------------------------------------------+
//|                                                      JB-HTML.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <jb-requests.mqh>

/* TO-DO

- fix bug: if there is the same tag within a tag, it will use the closing of the inner tag instead of outer tag

- create a function that will read the HTML and set it line-by-line in an array/structure
   - string title; holds the <title></title>
   - string body[]; holds all the tags in the body tag-by-tag

- translate HTML into MQL Objects

*/

enum ENUM_HTML_TAGS
  {
   a_,          // <a>
   abbr_,       // <abbr>
   address_,    // <address>
   area_,       // <area>
   article_,    // <article>
   aside_,      // <aside>
   audio_,      // <audio>
   b_,          // <b>
   base_,       // <base>
   bdi_,        // <bdi>
   bdo_,        // <bdo>
   blockquote_, // <blockquote>
   body_,       // <body>
   br_,         // <br>
   button_,     // <button>
   canvas_,     // <canvas>
   caption_,    // <caption>
   cite_,       // <cite>
   code_,       // <code>
   col_,        // <col>
   colgroup_,   // <colgroup>
   data_,       // <data>
   datalist_,   // <datalist>
   dd_,         // <dd>
   del_,        // <del>
   details_,    // <details>
   dfn_,        // <dfn>
   dialog_,     // <dialog>
   div_,        // <div>
   dl_,         // <dl>
   dt_,         // <dt>
   em_,         // <em>
   embed_,      // <embed>
   fieldset_,   // <fieldset>
   figcaption_, // <figcaption>
   figure_,     // <figure>
   footer_,     // <footer>
   form_,       // <form>
   h1_,         // <h1>
   h2_,         // <h2>
   h3_,         // <h3>
   h4_,         // <h4>
   h5_,         // <h5>
   h6_,         // <h6>
   head_,       // <head>
   header_,     // <header>
   hr_,         // <hr>
   html_,       // <html>
   i_,          // <i>
   iframe_,     // <iframe>
   img_,        // <img>
   input_,      // <input>
   ins_,        // <ins>
   kbd_,        // <kbd>
   label_,      // <label>
   legend_,     // <legend>
   li_,         // <li>
   link_,       // <link>
   main_,       // <main>
   map_,        // <map>
   mark_,       // <mark>
   meta_,       // <meta>
   meter_,      // <meter>
   nav_,        // <nav>
   noscript_,   // <noscript>
   object_,     // <object>
   ol_,         // <ol>
   optgroup_,   // <optgroup>
   option_,     // <option>
   output_,     // <output>
   p_,          // <p>
   param_,      // <param>
   picture_,    // <picture>
   pre_,        // <pre>
   progress_,   // <progress>
   q_,          // <q>
   rp_,         // <rp>
   rt_,         // <rt>
   ruby_,       // <ruby>
   s_,          // <s>
   samp_,       // <samp>
   script_,     // <script>
   section_,    // <section>
   select_,     // <select>
   small_,      // <small>
   source_,     // <source>
   span_,       // <span>
   strong_,     // <strong>
   style_,      // <style>
   sub_,        // <sub>
   summary_,    // <summary>
   sup_,        // <sup>
   table_,      // <table>
   tbody_,      // <tbody>
   td_,         // <td>
   template_,   // <template>
   textarea_,   // <textarea>
   tfoot_,      // <tfoot>
   th_,         // <th>
   thead_,      // <thead>
   time_,       // <time>
   title_,      // <title>
   tr_,         // <tr>
   track_,      // <track>
   u_,          // <u>
   ul_,         // <ul>
   var_,        // <var>
   video_,      // <video>
   wbr_         // <wbr>
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHTML
  {
public:
   CHTML::           CHTML() // constructor
     {

     }

   CHTML::          ~CHTML() // deconstructor
     {

     }


   // uses a GET requests to get the HTML from the url
   string            getHTMLFromURL(const string url)
     {
      this.jb = new CRequests();
      this.jb.url = url;
      this.jb.GET(5000,NULL,url);
      this.data = this.jb.result;
      delete this.jb;
      return this.data;
     }

   // Sets the value stored in the first element with that tag in the provided HTML to the strVariable
   bool              getElementByTag(const string HTML, string &strVariable, const ENUM_HTML_TAGS htmlTag = p_)
     {
      strVariable = NULL;

      this.htmltag = enumToTag(htmlTag);

      this.setTags(htmlTag);

      // Find start and end position for element
      if(this.midTag == "")
        {
         this.s = StringFind(HTML, this.startTag) + StringLen(this.startTag);
         this.e = StringFind(HTML, this.endTag, this.s);

         // Return element content
         if(this.e != -1)
           {
            strVariable = StringSubstr(HTML, this.s, this.e - this.s);
            return true;
           }
        }
      else
        {
         // Handles tags with a mid tag like <a href="url">content</a>
         // where <a is the start tag, > is the mid tag, and </a> is the end tag

         this.s = StringFind(HTML, this.startTag) + StringLen(this.startTag);
         this.m = StringFind(HTML, this.midTag, this.s) + StringLen(this.midTag);
         this.e = StringFind(HTML, this.endTag, this.m);

         // Return element content
         if(this.e != -1)
           {
            // return the content between the mid and end tags
            strVariable = StringSubstr(HTML, this.m, this.e - this.m);
            return true;
           }
        }



      return false;
     }

   // sets the values stored in the elements with that tag in the provided HTML to the strArray
   bool              getElementsByTag(const string HTML, string &strArray[], const ENUM_HTML_TAGS htmlTag = p_)
     {
      // Initialize variables
      this.loops = 0;
      this.startPos = 0;
      this.htmltag = enumToTag(htmlTag);
      this.setTags(htmlTag);

      // Resize array to a reasonable initial size
      ArrayResize(strArray, 1000);

      while((this.startPos = StringFind(HTML, this.startTag, this.startPos)) != -1)
        {
         // Find start and end position for element
         if(this.midTag == "")
           {
            this.s = this.startPos + StringLen(this.startTag);
            this.e = StringFind(HTML, this.endTag, this.s);
           }
         else
           {
            // Handles tags with a mid tag like <a href="url">content</a>
            // where <a is the start tag, > is the mid tag, and </a> is the end tag
            this.s = this.startPos + StringLen(this.startTag);
            this.m = StringFind(HTML, this.midTag, this.s) + StringLen(this.midTag);
            this.e = StringFind(HTML, this.endTag, this.m);
           }

         if(this.e == -1)
           {
            break; // No matching end tag found, exit loop
           }

         // Extract the content between start and end tag
         if(this.midTag == "")
           {
            this.htmlcontent = StringSubstr(HTML, this.s, this.e - this.s);
           }
         else
           {
            this.htmlcontent = StringSubstr(HTML, this.m, this.e - this.m);
           }

         // Save content to array
         strArray[this.loops] = this.htmlcontent;
         this.loops++;

         // Move startPos past the current end tag
         this.startPos = this.e + StringLen(this.endTag);
        }

      // Resize array to actual number of found elements
      ArrayResize(strArray, this.loops);

      return this.loops != 0;
     }

   // Sets the value stored in the first element with that ID in the provided HTML to the strVariable
   bool              getElementByID(const string HTML, string &strVariable, const string id)
     {
      strVariable = NULL;

      // Find start position of the ID
      this.idPosition = StringFind(HTML, "id=\"" + id + "\"");

      if(this.idPosition == -1)
        {
         return false;
        }

      this.setTags(findTag(HTML, this.idPosition));

      // Find start and end position for element
      if(this.midTag == "")
        {
         this.s += StringLen(this.startTag);
         this.e = StringFind(HTML, this.endTag, this.s);

         // Return element content
         if(this.e != -1)
           {
            strVariable = StringSubstr(HTML, this.s, this.e - this.s);
            return true;
           }
        }
      else
        {
         // Handles tags with a mid tag like <a href="url">content</a>
         // where <a is the start tag, > is the mid tag, and </a> is the end tag
         this.s += StringLen(this.startTag);
         this.m = StringFind(HTML, this.midTag, this.s) + StringLen(this.midTag);
         this.e = StringFind(HTML, this.endTag, this.m);

         // Return element content
         if(this.e != -1)
           {
            // Return the content between the mid and end tags
            strVariable = StringSubstr(HTML, this.m, this.e - this.m);
            return true;
           }
        }

      return false;
     }

   // Sets the values stored in the elements with that ID in the provided HTML to the strArray
   bool              getElementsByID(const string HTML, string &strArray[], const string id)
     {
      // Initialize variables
      this.loops = 0;
      this.startPos = 0;
      this.htmltag = "id=\"" + id + "\"";

      // Resize array to a reasonable initial size
      ArrayResize(strArray, 1000);

      while((this.idPosition = StringFind(HTML, this.htmltag, this.startPos)) != -1)
        {
         // Find the tag that contains the ID
         this.setTags(findTag(HTML, this.idPosition));

         // Find start and end position for element
         if(this.midTag == "")
           {
            this.s += StringLen(this.startTag);
            this.e = StringFind(HTML, this.endTag, this.s);
           }
         else
           {
            // Handles tags with a mid tag like <a href="url">content</a>
            // where <a is the start tag, > is the mid tag, and </a> is the end tag
            this.s += StringLen(this.startTag);
            this.m = StringFind(HTML, this.midTag, this.s) + StringLen(this.midTag);
            this.e = StringFind(HTML, this.endTag, this.m);
           }

         if(this.e == -1)
           {
            break; // No matching end tag found, exit loop
           }

         // Extract the content between start and end tag
         if(this.midTag == "")
           {
            this.htmlcontent = StringSubstr(HTML, this.s, this.e - this.s);
           }
         else
           {
            this.htmlcontent = StringSubstr(HTML, this.m, this.e - this.m);
           }

         // Save content to array
         strArray[this.loops] = this.htmlcontent;
         this.loops++;

         // Move startPos past the current end tag
         this.startPos = this.e + StringLen(this.endTag);
        }

      // Resize array to actual number of found elements
      ArrayResize(strArray, this.loops);

      return this.loops != 0;
     }

   bool              getElementByClass(const string HTML, string &strVariable, const string className)
     {
      strVariable = NULL;

      // Find start position of the class
      this.idPosition = StringFind(HTML, "class=\"" + className + "\"");

      if(this.idPosition == -1)
        {
         return false;
        }

      // sets this.s to where the most recent < is
      this.setTags(findTag(HTML, this.idPosition));
      

      // Find start and end position for element
      if(this.midTag == "")
        {
         this.s += StringLen(this.startTag);
         this.e = StringFind(HTML, this.endTag, this.s);

         // Return element content
         if(this.e != -1)
           {
            strVariable = StringSubstr(HTML, this.s, this.e - this.s);
            return true;
           }
        }
      else
        {
         // Handles tags with a mid tag like <a href="url">content</a>
         // where <a is the start tag, > is the mid tag, and </a> is the end tag
         
         this.s += StringLen(this.startTag);
         this.m = StringFind(HTML, this.midTag, this.s) + StringLen(this.midTag);
         this.e = StringFind(HTML, this.endTag, this.m);

         // Return element content
         if(this.e != -1)
           {
            // Return the content between the mid and end tags
            strVariable = StringSubstr(HTML, this.m, this.e - this.m);
            return true;
           }
        }

      return false;
     }

   // Sets the values stored in the elements with that class in the provided HTML to the strArray
   bool              getElementsByClass(const string HTML, string &strArray[], const string className)
     {
      // Initialize variables
      this.loops = 0;
      this.startPos = 0;

      // Resize array to a reasonable initial size
      ArrayResize(strArray, 1000);

      while((this.startPos = StringFind(HTML, "class=\"" + className + "\"", this.startPos)) != -1)
        {
         // Find the tag that contains the class
         // sets this.s to where the most recent < is
         setTags(findTag(HTML, this.startPos));

         // Find start and end position for element
         if(this.midTag == "")
           {
            this.s += StringLen(this.startTag);
            this.e = StringFind(HTML, this.endTag, this.s);
           }
         else
           {
            // Handles tags with a mid tag like <a href="url">content</a>
            // where <a is the start tag, > is the mid tag, and </a> is the end tag
            this.s += StringLen(this.startTag);
            this.m = StringFind(HTML, this.midTag, this.s) + StringLen(this.midTag);
            this.e = StringFind(HTML, this.endTag, this.m);
           }

         if(this.e == -1)
           {
            break; // No matching end tag found, exit loop
           }

         // Extract the content between start and end tag
         if(this.midTag == "")
           {
            this.htmlcontent = StringSubstr(HTML, this.s, this.e - this.s);
           }
         else
           {
            this.htmlcontent = StringSubstr(HTML, this.m, this.e - this.m);
           }

         // Save content to array
         strArray[this.loops] = this.htmlcontent;
         this.loops++;

         // Move startPos past the current end tag
         this.startPos = this.e + StringLen(this.endTag);
        }

      // Resize array to actual number of found elements
      ArrayResize(strArray, this.loops);

      return this.loops != 0;
     }




private:
   CRequests         *jb;
   string            data;
   string            htmltag, startTag, endTag, midTag;
   int               s,e,m,idPosition;
   string            htmlcontent;
   int               loops, startPos;

   void              setTags(const ENUM_HTML_TAGS htmlTag)
     {
      this.htmltag = enumToTag(htmlTag);

      this.startTag = "<" + this.htmltag + ">";
      this.endTag = "</" + this.htmltag + ">";

      switch(htmlTag)
        {
         case img_:
         case meta_:
         case link_:
         case input_:
         case param_:
         case source_:
         case track_:
            this.startTag = "<" + this.htmltag + " ";
            this.endTag = ">";
            this.midTag = "";
            break;
         case br_:
         case hr_:
         case wbr_:
            this.startTag = "<" + this.htmltag + ">";
            this.endTag = this.startTag;
            this.midTag = "";
            break;
         case a_:
         case div_:
         case main_:
         case span_:
         case section_:
            this.startTag = "<" + this.htmltag;
            this.midTag = ">";
            break;
         default:
            this.midTag = "";
            break;
        }
     }


   string            enumToTag(const ENUM_HTML_TAGS htmlTag)
     {
      switch(htmlTag)
        {
         case a_:
            return "a";
         case abbr_:
            return "abbr";
         case address_:
            return "address";
         case area_:
            return "area";
         case article_:
            return "article";
         case aside_:
            return "aside";
         case audio_:
            return "audio";
         case b_:
            return "b";
         case base_:
            return "base";
         case bdi_:
            return "bdi";
         case bdo_:
            return "bdo";
         case blockquote_:
            return "blockquote";
         case body_:
            return "body";
         case br_:
            return "br";
         case button_:
            return "button";
         case canvas_:
            return "canvas";
         case caption_:
            return "caption";
         case cite_:
            return "cite";
         case code_:
            return "code";
         case col_:
            return "col";
         case colgroup_:
            return "colgroup";
         case data_:
            return "data";
         case datalist_:
            return "datalist";
         case dd_:
            return "dd";
         case del_:
            return "del";
         case details_:
            return "details";
         case dfn_:
            return "dfn";
         case dialog_:
            return "dialog";
         case div_:
            return "div";
         case dl_:
            return "dl";
         case dt_:
            return "dt";
         case em_:
            return "em";
         case embed_:
            return "embed";
         case fieldset_:
            return "fieldset";
         case figcaption_:
            return "figcaption";
         case figure_:
            return "figure";
         case footer_:
            return "footer";
         case form_:
            return "form";
         case h1_:
            return "h1";
         case h2_:
            return "h2";
         case h3_:
            return "h3";
         case h4_:
            return "h4";
         case h5_:
            return "h5";
         case h6_:
            return "h6";
         case head_:
            return "head";
         case header_:
            return "header";
         case hr_:
            return "hr";
         case html_:
            return "html";
         case i_:
            return "i";
         case iframe_:
            return "iframe";
         case img_:
            return "img";
         case input_:
            return "input";
         case ins_:
            return "ins";
         case kbd_:
            return "kbd";
         case label_:
            return "label";
         case legend_:
            return "legend";
         case li_:
            return "li";
         case link_:
            return "link";
         case main_:
            return "main";
         case map_:
            return "map";
         case mark_:
            return "mark";
         case meta_:
            return "meta";
         case meter_:
            return "meter";
         case nav_:
            return "nav";
         case noscript_:
            return "noscript";
         case object_:
            return "object";
         case ol_:
            return "ol";
         case optgroup_:
            return "optgroup";
         case option_:
            return "option";
         case output_:
            return "output";
         case p_:
            return "p";
         case param_:
            return "param";
         case picture_:
            return "picture";
         case pre_:
            return "pre";
         case progress_:
            return "progress";
         case q_:
            return "q";
         case rp_:
            return "rp";
         case rt_:
            return "rt";
         case ruby_:
            return "ruby";
         case s_:
            return "s";
         case samp_:
            return "samp";
         case script_:
            return "script";
         case section_:
            return "section";
         case select_:
            return "select";
         case small_:
            return "small";
         case source_:
            return "source";
         case span_:
            return "span";
         case strong_:
            return "strong";
         case style_:
            return "style";
         case sub_:
            return "sub";
         case summary_:
            return "summary";
         case sup_:
            return "sup";
         case table_:
            return "table";
         case tbody_:
            return "tbody";
         case td_:
            return "td";
         case template_:
            return "template";
         case textarea_:
            return "textarea";
         case tfoot_:
            return "tfoot";
         case th_:
            return "th";
         case thead_:
            return "thead";
         case time_:
            return "time";
         case title_:
            return "title";
         case tr_:
            return "tr";
         case track_:
            return "track";
         case u_:
            return "u";
         case ul_:
            return "ul";
         case var_:
            return "var";
         case video_:
            return "video";
         case wbr_:
            return "wbr";
         default:
            return "p"; // Default case
        }
     }


   ENUM_HTML_TAGS    tagToEnum(string htmlTag)
     {
      if(StringFind(htmlTag, "<a ") == 0 || StringFind(htmlTag, "<a>") == 0)
         return a_;
      if(htmlTag == "<abbr>")
         return abbr_;
      if(htmlTag == "<address>")
         return address_;
      if(htmlTag == "<area>")
         return area_;
      if(htmlTag == "<article>")
         return article_;
      if(htmlTag == "<aside>")
         return aside_;
      if(htmlTag == "<audio>")
         return audio_;
      if(htmlTag == "<b>")
         return b_;
      if(htmlTag == "<base>")
         return base_;
      if(htmlTag == "<bdi>")
         return bdi_;
      if(htmlTag == "<bdo>")
         return bdo_;
      if(htmlTag == "<blockquote>")
         return blockquote_;
      if(htmlTag == "<body>")
         return body_;
      if(htmlTag == "<br>")
         return br_;
      if(htmlTag == "<button>")
         return button_;
      if(htmlTag == "<canvas>")
         return canvas_;
      if(htmlTag == "<caption>")
         return caption_;
      if(htmlTag == "<cite>")
         return cite_;
      if(htmlTag == "<code>")
         return code_;
      if(htmlTag == "<col>")
         return col_;
      if(htmlTag == "<colgroup>")
         return colgroup_;
      if(htmlTag == "<data>")
         return data_;
      if(htmlTag == "<datalist>")
         return datalist_;
      if(htmlTag == "<dd>")
         return dd_;
      if(htmlTag == "<del>")
         return del_;
      if(htmlTag == "<details>")
         return details_;
      if(htmlTag == "<dfn>")
         return dfn_;
      if(htmlTag == "<dialog>")
         return dialog_;
      if(StringFind(htmlTag, "<div ") == 0 || StringFind(htmlTag, "<div>") == 0)
         return div_;
      if(htmlTag == "<dl>")
         return dl_;
      if(htmlTag == "<dt>")
         return dt_;
      if(htmlTag == "<em>")
         return em_;
      if(htmlTag == "<embed>")
         return embed_;
      if(htmlTag == "<fieldset>")
         return fieldset_;
      if(htmlTag == "<figcaption>")
         return figcaption_;
      if(htmlTag == "<figure>")
         return figure_;
      if(htmlTag == "<footer>")
         return footer_;
      if(htmlTag == "<form>")
         return form_;
      if(htmlTag == "<h1>")
         return h1_;
      if(htmlTag == "<h2>")
         return h2_;
      if(htmlTag == "<h3>")
         return h3_;
      if(htmlTag == "<h4>")
         return h4_;
      if(htmlTag == "<h5>")
         return h5_;
      if(htmlTag == "<h6>")
         return h6_;
      if(htmlTag == "<head>")
         return head_;
      if(htmlTag == "<header>")
         return header_;
      if(htmlTag == "<hr>")
         return hr_;
      if(htmlTag == "<html>")
         return html_;
      if(htmlTag == "<i>")
         return i_;
      if(htmlTag == "<iframe>")
         return iframe_;
      if(StringFind(htmlTag, "<img ") == 0 || StringFind(htmlTag, "<img>") == 0)
         return img_;
      if(StringFind(htmlTag, "<input ") == 0 || StringFind(htmlTag, "<input>") == 0)
         return input_;
      if(htmlTag == "<ins>")
         return ins_;
      if(htmlTag == "<kbd>")
         return kbd_;
      if(htmlTag == "<label>")
         return label_;
      if(htmlTag == "<legend>")
         return legend_;
      if(htmlTag == "<li>")
         return li_;
      if(StringFind(htmlTag, "<link ") == 0 || StringFind(htmlTag, "<link>") == 0)
         return link_;
      if(StringFind(htmlTag, "<main ") == 0 || StringFind(htmlTag, "<main>") == 0)
         return main_;
      if(htmlTag == "<map>")
         return map_;
      if(htmlTag == "<mark>")
         return mark_;
      if(StringFind(htmlTag, "<meta ") == 0 || StringFind(htmlTag, "<meta>") == 0)
         return meta_;
      if(htmlTag == "<meter>")
         return meter_;
      if(htmlTag == "<nav>")
         return nav_;
      if(htmlTag == "<noscript>")
         return noscript_;
      if(htmlTag == "<object>")
         return object_;
      if(htmlTag == "<ol>")
         return ol_;
      if(htmlTag == "<optgroup>")
         return optgroup_;
      if(htmlTag == "<option>")
         return option_;
      if(htmlTag == "<output>")
         return output_;
      if(htmlTag == "<p>")
         return p_;
      if(StringFind(htmlTag, "<param ") == 0 || StringFind(htmlTag, "<param>") == 0)
         return param_;
      if(htmlTag == "<picture>")
         return picture_;
      if(htmlTag == "<pre>")
         return pre_;
      if(htmlTag == "<progress>")
         return progress_;
      if(htmlTag == "<q>")
         return q_;
      if(htmlTag == "<rp>")
         return rp_;
      if(htmlTag == "<rt>")
         return rt_;
      if(htmlTag == "<ruby>")
         return ruby_;
      if(htmlTag == "<s>")
         return s_;
      if(htmlTag == "<samp>")
         return samp_;
      if(htmlTag == "<script>")
         return script_;
      if(StringFind(htmlTag, "<section ") == 0 || StringFind(htmlTag, "<section>") == 0)
         return section_;
      if(htmlTag == "<select>")
         return select_;
      if(htmlTag == "<small>")
         return small_;
      if(StringFind(htmlTag, "<source ") == 0 || StringFind(htmlTag, "<source>") == 0)
         return source_;
      if(StringFind(htmlTag, "<span ") == 0 || StringFind(htmlTag, "<span>") == 0)
         return span_;
      if(htmlTag == "<strong>")
         return strong_;
      if(htmlTag == "<style>")
         return style_;
      if(htmlTag == "<sub>")
         return sub_;
      if(htmlTag == "<summary>")
         return summary_;
      if(htmlTag == "<sup>")
         return sup_;
      if(htmlTag == "<table>")
         return table_;
      if(htmlTag == "<tbody>")
         return tbody_;
      if(htmlTag == "<td>")
         return td_;
      if(htmlTag == "<template>")
         return template_;
      if(htmlTag == "<textarea>")
         return textarea_;
      if(htmlTag == "<tfoot>")
         return tfoot_;
      if(htmlTag == "<th>")
         return th_;
      if(htmlTag == "<thead>")
         return thead_;
      if(htmlTag == "<time>")
         return time_;
      if(htmlTag == "<title>")
         return title_;
      if(htmlTag == "<tr>")
         return tr_;
      if(htmlTag == "<track>")
         return track_;
      if(htmlTag == "<u>")
         return u_;
      if(htmlTag == "<ul>")
         return ul_;
      if(htmlTag == "<var>")
         return var_;
      if(htmlTag == "<video>")
         return video_;
      if(htmlTag == "<wbr>")
         return wbr_;

      // Default case
      return p_;
     }


   // Helper function to find the tag starting at a given position
   ENUM_HTML_TAGS    findTag(const string HTML, int startPosition)
     {
      // Find the first tag starting at startPos in the HTML
      this.s = -1;

      // loop backwards to see if that letter is a <, if it is then we have found the start of the tag
      for(int i = startPosition; i >= 0; i--)
        {
         if(StringSubstr(HTML, i, 1) == "<")
           {
            this.s = i;
            break;
           }
        }


      if(this.s == -1)
         return p_;

      // Get up to 10 characters including the < (example <a href="url">)
      string tag = StringSubstr(HTML, this.s, 10);

      if(StringFind(tag, "<a ") == 0 || StringFind(tag, "<a>") == 0)
         return a_;
      if(StringFind(tag, "<abbr>") == 0)
         return abbr_;
      if(StringFind(tag, "<address>") == 0)
         return address_;
      if(StringFind(tag, "<area>") == 0)
         return area_;
      if(StringFind(tag, "<article>") == 0)
         return article_;
      if(StringFind(tag, "<aside>") == 0)
         return aside_;
      if(StringFind(tag, "<audio>") == 0)
         return audio_;
      if(StringFind(tag, "<b>") == 0)
         return b_;
      if(StringFind(tag, "<base>") == 0)
         return base_;
      if(StringFind(tag, "<bdi>") == 0)
         return bdi_;
      if(StringFind(tag, "<bdo>") == 0)
         return bdo_;
      if(StringFind(tag, "<blockquote>") == 0)
         return blockquote_;
      if(StringFind(tag, "<body>") == 0)
         return body_;
      if(StringFind(tag, "<br>") == 0)
         return br_;
      if(StringFind(tag, "<button>") == 0)
         return button_;
      if(StringFind(tag, "<canvas>") == 0)
         return canvas_;
      if(StringFind(tag, "<caption>") == 0)
         return caption_;
      if(StringFind(tag, "<cite>") == 0)
         return cite_;
      if(StringFind(tag, "<code>") == 0)
         return code_;
      if(StringFind(tag, "<col>") == 0)
         return col_;
      if(StringFind(tag, "<colgroup>") == 0)
         return colgroup_;
      if(StringFind(tag, "<data>") == 0)
         return data_;
      if(StringFind(tag, "<datalist>") == 0)
         return datalist_;
      if(StringFind(tag, "<dd>") == 0)
         return dd_;
      if(StringFind(tag, "<del>") == 0)
         return del_;
      if(StringFind(tag, "<details>") == 0)
         return details_;
      if(StringFind(tag, "<dfn>") == 0)
         return dfn_;
      if(StringFind(tag, "<dialog>") == 0)
         return dialog_;
      if(StringFind(tag, "<div ") == 0 || StringFind(tag, "<div>") == 0)
         return div_;
      if(StringFind(tag, "<dl>") == 0)
         return dl_;
      if(StringFind(tag, "<dt>") == 0)
         return dt_;
      if(StringFind(tag, "<em>") == 0)
         return em_;
      if(StringFind(tag, "<embed>") == 0)
         return embed_;
      if(StringFind(tag, "<fieldset>") == 0)
         return fieldset_;
      if(StringFind(tag, "<figcaption>") == 0)
         return figcaption_;
      if(StringFind(tag, "<figure>") == 0)
         return figure_;
      if(StringFind(tag, "<footer>") == 0)
         return footer_;
      if(StringFind(tag, "<form>") == 0)
         return form_;
      if(StringFind(tag, "<h1>") == 0)
         return h1_;
      if(StringFind(tag, "<h2>") == 0)
         return h2_;
      if(StringFind(tag, "<h3>") == 0)
         return h3_;
      if(StringFind(tag, "<h4>") == 0)
         return h4_;
      if(StringFind(tag, "<h5>") == 0)
         return h5_;
      if(StringFind(tag, "<h6>") == 0)
         return h6_;
      if(StringFind(tag, "<head>") == 0)
         return head_;
      if(StringFind(tag, "<header>") == 0)
         return header_;
      if(StringFind(tag, "<hr>") == 0)
         return hr_;
      if(StringFind(tag, "<html>") == 0)
         return html_;
      if(StringFind(tag, "<i>") == 0)
         return i_;
      if(StringFind(tag, "<iframe>") == 0)
         return iframe_;
      if(StringFind(tag, "<img ") == 0 || StringFind(tag, "<img>") == 0)
         return img_;
      if(StringFind(tag, "<input ") == 0 || StringFind(tag, "<input>") == 0)
         return input_;
      if(StringFind(tag, "<ins>") == 0)
         return ins_;
      if(StringFind(tag, "<kbd>") == 0)
         return kbd_;
      if(StringFind(tag, "<label>") == 0)
         return label_;
      if(StringFind(tag, "<legend>") == 0)
         return legend_;
      if(StringFind(tag, "<li>") == 0)
         return li_;
      if(StringFind(tag, "<link ") == 0 || StringFind(tag, "<link>") == 0)
         return link_;
      if(StringFind(tag, "<main ") == 0 || StringFind(tag, "<main>") == 0)
         return main_;
      if(StringFind(tag, "<map>") == 0)
         return map_;
      if(StringFind(tag, "<mark>") == 0)
         return mark_;
      if(StringFind(tag, "<meta ") == 0 || StringFind(tag, "<meta>") == 0)
         return meta_;
      if(StringFind(tag, "<meter>") == 0)
         return meter_;
      if(StringFind(tag, "<nav>") == 0)
         return nav_;
      if(StringFind(tag, "<noscript>") == 0)
         return noscript_;
      if(StringFind(tag, "<object>") == 0)
         return object_;
      if(StringFind(tag, "<ol>") == 0)
         return ol_;
      if(StringFind(tag, "<optgroup>") == 0)
         return optgroup_;
      if(StringFind(tag, "<option>") == 0)
         return option_;
      if(StringFind(tag, "<output>") == 0)
         return output_;
      if(StringFind(tag, "<p>") == 0)
         return p_;
      if(StringFind(tag, "<param ") == 0 || StringFind(tag, "<param>") == 0)
         return param_;
      if(StringFind(tag, "<picture>") == 0)
         return picture_;
      if(StringFind(tag, "<pre>") == 0)
         return pre_;
      if(StringFind(tag, "<progress>") == 0)
         return progress_;
      if(StringFind(tag, "<q>") == 0)
         return q_;
      if(StringFind(tag, "<rp>") == 0)
         return rp_;
      if(StringFind(tag, "<rt>") == 0)
         return rt_;
      if(StringFind(tag, "<ruby>") == 0)
         return ruby_;
      if(StringFind(tag, "<s>") == 0)
         return s_;
      if(StringFind(tag, "<samp>") == 0)
         return samp_;
      if(StringFind(tag, "<script>") == 0)
         return script_;
      if(StringFind(tag, "<section ") == 0 || StringFind(tag, "<section>") == 0)
         return section_;
      if(StringFind(tag, "<select>") == 0)
         return select_;
      if(StringFind(tag, "<small>") == 0)
         return small_;
      if(StringFind(tag, "<source ") == 0 || StringFind(tag, "<source>") == 0)
         return source_;
      if(StringFind(tag, "<span>") == 0)
         return span_;
      if(StringFind(tag, "<strong>") == 0)
         return strong_;
      if(StringFind(tag, "<style>") == 0)
         return style_;
      if(StringFind(tag, "<sub>") == 0)
         return sub_;
      if(StringFind(tag, "<summary>") == 0)
         return summary_;
      if(StringFind(tag, "<sup>") == 0)
         return sup_;
      if(StringFind(tag, "<table>") == 0)
         return table_;
      if(StringFind(tag, "<tbody>") == 0)
         return tbody_;
      if(StringFind(tag, "<td>") == 0)
         return td_;
      if(StringFind(tag, "<template>") == 0)
         return template_;
      if(StringFind(tag, "<textarea>") == 0)
         return textarea_;
      if(StringFind(tag, "<tfoot>") == 0)
         return tfoot_;
      if(StringFind(tag, "<th>") == 0)
         return th_;
      if(StringFind(tag, "<thead>") == 0)
         return thead_;
      if(StringFind(tag, "<time>") == 0)
         return time_;
      if(StringFind(tag, "<title>") == 0)
         return title_;
      if(StringFind(tag, "<tr>") == 0)
         return tr_;
      if(StringFind(tag, "<track>") == 0)
         return track_;
      if(StringFind(tag, "<u>") == 0)
         return u_;
      if(StringFind(tag, "<ul>") == 0)
         return ul_;
      if(StringFind(tag, "<var>") == 0)
         return var_;
      if(StringFind(tag, "<video>") == 0)
         return video_;
      if(StringFind(tag, "<wbr>") == 0)
         return wbr_;

      // Default case
      return p_;
     }


  };
//+------------------------------------------------------------------+
