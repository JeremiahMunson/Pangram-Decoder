# These global variables are the keys/values for the code
# The key is the code and value is english for codeToEnglish
# Vice Versa for englishToCode
$codeToEnglish = Hash.new()
$englishToCode = Hash.new()

class Pangram
    def initialize(line)
        @fullPangram = line
        @size, @strippedPangram = strip(line)
    end

    def fullPangram
        @fullPangram
    end
    def strippedPangram
        @strippedPangram
    end
    def size
        @size
    end
end

######## Functions #########

# This next part strips away all the unwanted characters (white space, commas, quotes, dashes, etc.)
def strip(line)
    validCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
    newLine = ""
    numberChars = 0
    line.each_char do |character|
        for valid in validCharacters
            if (character == valid) 
                newLine+=character
                numberChars+=1
                break
            end
        end
    end
    return numberChars, newLine
end

# This uses the codeToEnglish and englishToCode hash tables into a key for the code
def solveCode(pangram, code)
    for index in 0..pangram.length
        char = code[index]
        letter = pangram[index]
        if !$codeToEnglish.key?(char) 
            $codeToEnglish[char] = letter 
        end
        if !$englishToCode.key?(letter) 
            $englishToCode[letter] = char 
        end
    end
end


##### Program #####

# Reading in the list of pangrams stored in pangrams.txt
file = File.new("pangrams.txt", "r")
list = Array.new()
while (line = file.gets)
    list.push(line)
end
file.close

# Want pangrams to be stored in this hash table where the number of characters is the key
# The value is an array of pangrams with the same length
pangrams = Hash.new()

for line in list
    numberChars, newLine = strip(line)
    # This is an if statement, if key in use append, otherwise make new key/value
    pangrams.key?(numberChars) ? pangrams[numberChars].push(Pangram.new(line)) : pangrams[numberChars] = [Pangram.new(line)] 
end

# Getting the user input code
codedPangram = gets.chomp
lengthCode, strippedCode = strip(codedPangram)



## Making sure solveCode works
solveCode(pangrams[26][0].strippedPangram, strippedCode)
# Prints code to english comparison
puts "Code: English"
for keys,vals in $codeToEnglish
    break if(vals == nil)
    comparison = keys + ": " + vals
    puts comparison
end