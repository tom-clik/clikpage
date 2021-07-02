# Media Queries

Media queries are defined as variables like colors and fonts, but are written out in the CSS in full each time.

All styling in Clikpage needs to be in a "medium" of some description. The medium "main" applies no media query.

Other media queries can be defined with a minimum and or maximum width.

Typical definitions are "mobile" and "mid". You might also define "wide". The definition would be so:

    <media>
        <medium name="main" />
        <medium name="wide" min="1200" />
        <medium name="mid" max="800" />
        <medium name="mobile" max="600" />
    </media>

Note the order is important. Main styles would override mobile styles if they came after. CSS doesn't apply specificity on the basis of media.

The "main" definition is optional and it will always be applied to the start.

All styling applied to content needs to be in a medium, e.g.

    <topmenu>
        <main>
            <height>100%</height>
        </main>
        <mid>
           <height>auto</height>
        </mid>
        <mobile>
            <show>0</show>
        </mobile>           
    </topmenu>





















