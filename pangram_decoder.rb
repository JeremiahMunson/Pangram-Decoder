file = File.new("pangrams.txt", "r")
list = Array.new()
while (line = file.gets)
    list.push(line)
end
file.close

valid = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']

pangrams = Hash.new()

for line in list
    newLine = ""
    numberChars = 0
    line.each_char do |character|
        for validChar in valid
            if (character == validChar) 
                newLine+=character
                numberChars+=1
                break
            end
        end
    end
    pangrams.key?(numberChars) ? pangrams[numberChars].push(newLine) : pangrams[numberChars] = [newLine] 
end

puts pangrams[26]