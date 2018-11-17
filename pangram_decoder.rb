# These global variables are the keys/values for the code
# The key is the code and value is english for codeToEnglish
# Vice Versa for englishToCode
$codeToEnglish = Hash.new()
$englishToCode = Hash.new()

# Want pangrams to be stored in this hash table where the number of characters is the key
# The value is an array of pangrams with the same length
$pangrams = Hash.new()

# The only characters we care about are letters and numbers if the user wants to user numbers as part of the code
$validCharacters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

# Each pangram and the code become Pangram objects allowing for easier access to the full and stripped version of a single pangram
class Pangram
    def initialize(line)
        @fullPangram = line
        @strippedPangram = line.gsub(/\s+/, '')
    end

    def fullPangram
        @fullPangram
    end
    def strippedPangram
        @strippedPangram
    end

    def ==(other)
        # If other doesn't match the size of this pangram it can't be a match
        return false if (other.strippedPangram.length != @strippedPangram.length)
        return false if (other.fullPangram.length != @fullPangram.length)

        # If sizing matches then find number of words and size of each word
        # If number of words and/or size of each word (in order) doesn't match not the same
        theseWords = SeperateWords(@fullPangram)
        otherWords = SeperateWords(other.fullPangram) 
        return false if (theseWords.length != otherWords.length)
        for index in 0..(theseWords.length - 1)
            return false if(theseWords[index].length != otherWords[index].length)
        end
        # If it's a pure pangram with just 26 characters that's all this can check for so it's a match
        return true if (@strippedPangram.length == 26)

        # If the pangram has more than 26 characters this checks to see whether or not the repeated characters match
        thisRepeats = Repeats(@strippedPangram)
        otherRepeats = Repeats(other.strippedPangram)
        # May not be in the same order so have to loop through both
        thisRepeats.each do |thisCharRepeat|
            differentRepeats = true
            otherRepeats.each {|otherCharRepeat| differentRepeats = false if (thisCharRepeat == otherCharRepeat)}
            return false if differentRepeats
        end

        # If it gets here without returning false it's a match
        return true
    end

    # SeperateWords (Pangram.fullPangram): Seperates a phrase into an array of words in the phrase
    # returns array of strings where each string is a word in the phrase and the array as a whole is the phrase
    def SeperateWords(phrase)
        #word: array of characters where the array is a word
        word = String.new() # looking back I don't know why I made this an array, not a string...but it works and I don't want to mess with it right now, maybe later
        #words: array of arrays of characters where array of characters is a word 
        words = Array.new()
    
        # Filling words
        phrase.each_char do |character|
            # false = white space, true = valid letter
            foundValid = false
            # if the character is valid then add it to the word
            $validCharacters.each do |valid|
                # A space should seperate words
                if (character == valid)
                    word+=character
                    foundValid = true
                   break
                end
            end
            # if the character wasn't a valid character it must be white space (or at least some kind of word-ending/seperating character) so the word stops there
            # added word.length > 0 to make sure it didn't do something weird in case there were back to back white spaces but this should never happen (but it doesn't hurt to be safe)
            if(!foundValid && word.length > 0)
                words.push(word)
                word = String.new() # needs to start from being empty so that the previous word isn't carried over into the next word
            end
        end
        return words
    end

    # Repeats (Pangram.strippedPangram): Finds the repeated character locations for the input Pangram 
    # returns an Array of arrays where the arrays are the locations of characters that appear more than once in the phrase
    # ex: str = "chopping wood" - repeats : Hash[o] = [2,10,11]; Hash[p] = [3,4]... returns [[2,10,11],[3,4]]
    def Repeats(phrase)
        # phraseLetters: hash table where a-z are the keys and the locations of the characters as 1D Arrays are the values
        phraseLetters = Hash.new()
        for index in 0..(phrase.length - 1)
            character = phrase[index]
            phraseLetters.has_key?(character) ? phraseLetters[character].push(index) : phraseLetters[character] = [index]
        end

        # phraseRepeats: Array of arrays where the arrays are the locations of characters that appear more than once in the phrase
        phraseRepeats = Array.new()
        phraseLetters.each do |letters, placement|
            # If it appears only once it doesn't matter, this is checking for repeated values
            if placement.length > 1
                phraseRepeats.push(placement)
            elsif placement.length < 1
                puts "NOT A PANGRAM! PANGRAMS USE ALL 26 LETTERS IN THE ALPHABET AND THIS DOESN'T USE ALL OF THEM!"
            end
        end
        return phraseRepeats
    end
end

######## Functions #########

# SolveCode(Pangram.strippedPangram, Pangram.strippedPangram): takes a Pangram (the code) and a Pangram (the pangram used for the code)
# It "solves" the code by filling in $codeToEnglish and $englishToCode
# returns nothing, just makes changes to global variables ^^
def SolveCode(code, pangram)
    # did 'index in 0..pangram.length' instead of 'something in pangram' because it needs to go through pangram and code together and index like this works for both
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

# PrintCodeToEnglish(): Prints code to english comparison
def PrintCodeToEnglish()
    puts "Code: English"
    $codeToEnglish.each do |keys,vals|
        break if(vals == nil)
        comparison = keys + ": " + vals
        puts comparison
    end
end

# PrintEnglishToCode(): Prints english to code comparison
def PrintEnglishToCode()
    puts "English: Code"
    $validCharacters.each do |valid|
        comparison = valid + ": " + $englishToCode[valid]
        puts comparison
    end
end

## May not work after changes
def TestPangrams(list)
    pangramNumber = 1
    list.each do |listedPangram|
        testPangram = Pangram.new(listedPangram)
        strippedListed = testPangram.strippedPangram
        lengthCode = strippedListed.length

        # If the length of the pangram doesn't match the length of any stored pangram it beat the program
        if(!$pangrams.key?(lengthCode))
            puts "The input does not match any stored pangram!"
        elsif($pangrams[lengthCode].length == 1)
            puts pangramNumber.to_s + ":Success" #$pangrams[lengthCode][0].fullPangram
        else
            ## TODO: A LOT HAS CHANGED SINCE I MADE THIS...WOW
            usedPangram = findPangram(listedPangram, strippedListed)
            if (usedPangram == nil)
                puts "Repeat char size, total size, and individual word sizes!"
            else
                puts pangramNumber.to_s + ":Success" #usedPangram.fullPangram
            end
        end
        pangramNumber+=1
    end
end

######################### END OF FUNCTIONS ##################################

################### Loading pangrams and making pangrams into pangram objects w/ stripped pangrams###################
file = File.new("pangrams.txt", "r")
list = Array.new()
while (line = file.gets)
    list.push(line.chomp)
end
file.close

list.each do |line|
    newLine = line.gsub(/\s+/, '')#Strip(line)
    # This is an if statement, if key in use append, otherwise make new key/value
    $pangrams.key?(newLine.length) ? $pangrams[newLine.length].push(Pangram.new(line)) : $pangrams[newLine.length] = [Pangram.new(line)] 
end

###################### Getting the user input code ##############################
puts "Please input coded pangram (do not include any hyphens, commas, quotes, periods, etc. only the 'letters' and spaces):"

while true
    codedPangram = gets.chomp
        
    ####################### CLEANING USER INPUT CODED PANGRAM ##################################
    ## Need to clean the input so that checking the full length against pangram full lengths is accurate
    codedPangram = codedPangram.tr('\'', '')
    codedPangram.downcase!
    # Removing unwanted characters and replacing them with whitespace
    for index in 0..(codedPangram.length - 1)
        invalid = true
        $validCharacters.each do |valid|
            if valid == codedPangram[index]
                invalid = false
                break
            end
        end
        if invalid
            codedPangram[index] = " "
        end
    end
    # Removing extra whitespace at beginning an end
    codedPangram.strip!
    # Removing back to back whitespaces
    for index in 0..(codedPangram.length-2)
        if ((codedPangram[index] == " " && codedPangram[index+1] == " " )|| (codedPangram[index] == " " && codedPangram[index-1] == " " ))
            codedPangram[index] = ''
        end
    end

    code = Pangram.new(codedPangram)

    break if(code.strippedPangram.length >= 26)
    puts "Not all letters are used, please input a pangram (a phrase that uses all 26 letters in the english alphabet:"
end

puts "Would you like to compare the coded with english by English:Code (E) or Code:English (C):"
while true
    comparisonVersion = gets.chomp
    comparisonVersion.upcase!
    break if(comparisonVersion == 'E' || comparisonVersion == 'C')
    puts "Invalid options...please input an E for English:Code or C for Code:English"
end

######################################## CHECKING INPUT AGAINST PANGRAMS ####################################################
foundPangrams = Array.new()

# If no pangrams with same number of characters can't find it
if($pangrams.has_key?((code.strippedPangram).length))
    # Just have to go through the pangrams of the same length
    $pangrams[(code.strippedPangram).length].each do |pangram|
        foundPangrams.push(pangram) if (code == pangram) #if pangram matches code length, word sizes and order, and repeated characters it is a possible match
    end
end

# If one possible match found then it must be that, otherwise it can't be determined from given information
if (foundPangrams.length == 1)
    puts foundPangrams[0].fullPangram
    SolveCode(code.strippedPangram, foundPangrams[0].strippedPangram)
    comparisonVersion == 'E' ? PrintEnglishToCode() : PrintCodeToEnglish()
elsif(foundPangrams.length > 1)
    puts "Too many pangrams found, could not determine which one was used:"
    foundPangrams.each {|possible| puts possible.fullPangram} # Was used for some debugging but like having it in general
else
    puts "Could not find a pangram that matches coded pangram."
end