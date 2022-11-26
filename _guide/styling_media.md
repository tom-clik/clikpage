# Media Queries

All styling in Clikpage needs to be in a "medium" of some description. The medium "main" applies no media query. The others can be defined with a minimum and/or a maximum width.

Typical definitions are "mobile" and "mid". You might also define "wide". The definition would be so:
 
    <media>
        <medium name="wide" min="1200" />
        <medium name="mid" max="800" />
        <medium name="mobile" max="600" />
        <medium name="print" media="print" />
    </media>

Note the order is important.The "main" medium is always prepended to the list. The others are applied in order. Styles specified without a medium are applied to the main medium.

    <topmenu>
        <height>100%</height>
        <mid>
           <height>auto</height>
        </mid>
        <mobile>
            <show>0</show>
        </mobile>           
    </topmenu>

