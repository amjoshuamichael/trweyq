local available = "a b c d e f g h i j k l m n o p q r s t u v w x y z space"
GameChars = {}

function InitializeCharsObject()
    for c, char in pairs(Split(available, " ")) do
        GameChars[char] = true
    end
end