---
title: Your Dissertation Title
author: Your Name
date: "2024"
documentclass: report
fontsize: 12pt
linestretch: 2
indent: true
classoption: openany
parskip: 12pt
geometry:
  - top=1in
  - bottom=1in
  - left=1.25in
  - right=1.25in
  - width=6.5in
  - textwidth=6.50in
bibliography: bibliography.bib
csl: chicago-note-bibliography.csl
header-includes: |
    % Store the original chapter format
    \let\originalchapterformat\chapter
    
    % Define special chapter format
    \newcommand{\specialchapterformat}{%
        \titleformat{\chapter}[display]
            {\normalfont\huge\bfseries}{\chaptertitlename\ \thechapter}{20pt}{\Large}
        \titlespacing{\chapter}{0pt}{160pt}{40pt}
    }
    
    % Command to restore original format
    \newcommand{\restorechapterformat}{%
        \titleformat{\chapter}[display]
            {\normalfont\huge\bfseries}{\chaptertitlename\ \thechapter}{20pt}{\Huge}
        \titlespacing{\chapter}{0pt}{50pt}{40pt}
    }
---

\pagenumbering{roman} 
\tableofcontents 
\listoffigures 


\pagenumbering{arabic}

\begin{savequote}[12cm]
---When shall we three meet again
in thunder, lightning, or in rain?
---When the hurlyburly’s done,
when the battle’s lost and won.
\qauthor{Shakespeare, Macbeth}
Cookies! Give me some cookies!
\qauthor{Cookie Monster}
\end{savequote}

\specialchapterformat
\chapter{1. The Social Life of Rabbits}
\setcounter{chapter}{1}
![[chapters/chapter1]]

\restorechapterformat
\setcounter{chapter}{2}
![[chapters/chapter2]]

![[chapters/Images]]

\singlespacing

\chapter*{Bibliography}
