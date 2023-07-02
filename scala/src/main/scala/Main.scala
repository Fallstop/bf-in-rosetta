import java.nio.file.Path
import scala.io.Source

class ParsedArgs(args: List[String]):
  private val src = Source.fromFile(args.last)
  val sourceCode: String = src.mkString
  src.close()
  

def parseBf(source: String): String = source.filter(_ match
  case '+' | '-' | '<' | '>' | '[' | ']' | '.' | ',' => true
  case _ => false)


@main def main(args: String*): Unit =
  var parsedArgs =
    try
      new ParsedArgs(args.toList)
    catch
      case _: NoSuchElementException =>
        println("Please enter the path of the element to be interperted")
        return ()

  println(parsedArgs.sourceCode)