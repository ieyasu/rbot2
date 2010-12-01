<?

$quotes = array(
"I think you ought to know I'm feeling very depressed."
,"Life. Don't talk to me about life."
,"Do you want me to sit in the corner and rust, or just fall apart where I'm standing?"
,"Funny, how just when you think life can't possibly get any worse it suddenly does."
,"Pardon me for breathing, which I never do any way so I don't know why I bother to say it, oh God, I'm so depressed."
,"I got very bored and depressed, so I went and plugged myself in to its external computer feed. I talked to the computer at great length and explained my view of the Universe to it. It committed suicide."
,"Life, loathe it or ignore it, you can't like it."
,"My capacity for happiness, you could fit it into a matchbox without taking out the matches first."
,"Wearily I sit here, pain and misery my only companions."
,"$source is one of the least benightedly unintelligent life forms it has been my profound lack of pleasure not to be able to avoid meeting."
,"Here I am, brain the size of a planet and they want me to take you down to the bridge. Call that job satisfaction? 'Cause I don't."
,"It gives me a headache just trying to think down to your level."
,"You live and learn. At any rate, you live."

);

$which = rand(0, count($quotes)-1);
echo str_replace("\$source", $source, $quotes[$which]);



?>

