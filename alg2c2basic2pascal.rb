#!/usr/bin/env ruby
# encoding: utf-8

code = ARGF.read
if code.empty?
  code = IO.read 'sample_code.alg'
end

# Симулятор ридлайна, используется при неинтерактивной работе
# Укажите значения, которое будут переданы в readline
@readline_vals = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

# код ниже не нужно редактировать

code.gsub!(/алг$/i, "")
code.gsub!(/;/, "\n")
code.gsub!(/вывод (.+)/i) { |vars|
  $1.gsub(/нс,?\s?/, '').gsub(/([^,]+),?/i, "вывод \\1\n" )
}

def toC (code)
  divmod! code
  code = "#include <stdio.h>\n" + code
  code.gsub!(/иначе/i, "} else {")
  code.gsub!(/\sи\s/, ' && ')
  code.gsub!(/\sили\s/, ' || ')
  code.gsub!(/алг\s+([^\s]+)\s+([a-z_]+[a-z0-9_]*)\((.*)\)[\s\n]*нач(.*?)кон/im, "function \\1 \\2 (\\3) { \\4 }")
  code.gsub!(/знач :=\s?(.*)/i, 'return \\1;')
  code.gsub!(/нач/i, 'void main() {')
  code.gsub!(/кон/i, '}')
  code.gsub!(/целтаб ([a-z]+[a-z_0-9]*)\[(.*):(.*)\]/i, "int \\1[\\3];")
  code.gsub!(/(.*?)цел ([a-z]+[a-z0-9_]*)\s?=\s?([0-9]+)/im, "#define \\2 \\3\n\\1")
  code.gsub!(/^\s*цел (.*)\n/i, "int \\1;\n")
  code.gsub!(/цел ([a-z_]+[a-z0-9_]*)/i, "int \\1")
  code.gsub!(/^\s*вещ (.*)\n/i, "float \\1;\n")
  code.gsub!(/вещ ([a-z_]+[a-z0-9_]*)/i, "float \\1")
  code.gsub!(/\s\=\s/, '==')
  code.gsub!(/(.*):=(.*)\n/, "\\1=\\2;\n")
  code.gsub!(/нц пока (.*)/i, "while (\\1) {")
  code.gsub!(/нц для ([a-z]+) от ([a-z0-9]+) до ([a-z0-9]+)/i, "for (\\1 = \\2; \\1 <= \\3; \\1++) {")
  code.gsub!(/кц/i, '}')
  code.gsub!(/если (.*?) то(.*?)все/im, "if (\\1) {\\2}")
  code.gsub!(/вывод (.*)/i, %{printf("%d", \\1);})
  code.gsub!(/ввод (.*)/i, %{scanf("%d", &\\1);})
  code.gsub!(/'/, '"')
  code
end

def toBasic (code)
  code.gsub!(/иначе/i, "ELSE")
  code.gsub!(/\sи\s/, ' AND ')
  code.gsub!(/\sили\s/, ' OR ')
  code.gsub!(/алг\s+([^\s]+)\s+([a-z_]+[a-z0-9_]*)\((.*)\)[\s\n]*нач(.*?)знач\s?:=(.*?)кон/im, "FUNCTION \\2 (\\3)\n \\4\n \\2 =\\5 END FUNCTION")
  code.gsub!(/(?:нач|кон)\n/i, '')
  code.gsub!(/^\s*цел (.*)\s?=\s?(.*)/i, "CONST \\1 = \\2")
  code.gsub!(/целтаб ([a-z]+[a-z_0-9]*)\[(.*):(.*)\]/i, "DIM \\1(\\3) AS INTEGER")
  code.gsub!(/^\s*цел (.*)\n/i, "DIM \\1 AS INTEGER\n")
  code.gsub!(/цел ([a-z_]+[a-z0-9_]*)/i, "\\1")
  code.gsub!(/(.*):=(.*)\n/, "\\1=\\2\n")
  code.gsub!(/нц пока (.*?)кц/im, "WHILE \\1END")
  code.gsub!(/нц для ([a-z0-9]+) от ([a-z0-9]+) до ([a-z0-9]+)(.*?)кц/im, "FOR \\1 = \\2 TO \\3 \\4NEXT \\1")
  code.gsub!(/([a-z0-9]+)\[(.*?)\]/i, "\\1(\\2)")
  code.gsub!(/если (.*?) то(.*?)все/im, "IF \\1 THEN \\2 END")
  code.gsub!(/вывод (.*)/i, "PRINT \\1")
  code.gsub!(/ввод (.*)/i, "INPUT \\1")
  divmod! code, 'DIV', 'MOD'
  code
end

def toPascal (code)
  code.gsub!(/иначе/i, "else")
  code.gsub!(/\sи\s/, ' and ')
  code.gsub!(/\sили\s/, ' or ')
  code.gsub!(/(.*)алг\s+([^\s]+)\s+([a-z_]+[a-z0-9_]*)\((.*)\)[\s\n]*нач(.*?)знач\s?:=(.*?)кон/im, "Function \\3 (\\4): \\2\nbegin \\5\n \\3 := \\6end;\\1")
  code.gsub!(/нач/i, '')
  code.gsub!(/кон/i, 'end.')
  code.gsub!(/^(.*)цел ([a-z]+[a-z0-9_]*)\s?=\s?(.*?)\n/im, "const\n \\2 = \\3;\n\\1")
  code.gsub!(/целтаб ([a-z]+[a-z_0-9]*)\[(.*):(.*)\]/i, "\\1: array [\\2..\\3] of integer;")
  code.gsub!(/^\s*цел (.*)\n/i, "var \\1: integer;\nbegin\n")
  code.gsub!(/цел ([a-z_]+[a-z0-9_]*)/i, "\\1: integer")
  code.gsub!(/:\s*цел\s*$/i, ": integer")
  code.gsub!(/^\s*вещ (.*)\n/i, "var \\1: real;\nbegin\n")
  code.gsub!(/вещ ([a-z_]+[a-z0-9_]*)/i, "\\1: real")
  code.gsub!(/:\s*вещ\s*$/i, ": real")
  code.gsub!(/(.*):=(.*)\n/, "\\1:=\\2;\n")
  code.gsub!(/нц пока (.*)/i, "while \\1 do")
  code.gsub!(/нц для ([a-z]+) от ([a-z0-9]+) до ([a-z0-9]+)/i, "for \\1 := \\2 to \\3 do begin")
  code.gsub!(/кц/i, 'end;')
  code.gsub!(/если (.*?) то(.*?)все/im, "if \\1 then \\2 end;")
  code.gsub!(/вывод (.*)/i, "writeln(\\1);")
  code.gsub!(/ввод (.*)/i, "readln(\\1);")
  code
end

def toRuby (code)
  code.gsub!(/иначе/i, "else")
  code.gsub!(/\sи\s/, ' and ')
  code.gsub!(/\sили\s/, ' or ')
  code.gsub!(/(.*)алг\s+([^\s]+)\s+([a-z_]+[a-z0-9_]*)\((.*)\)[\s\n]*нач(.*?)кон/im, "def \\3(\\4)\n \\5 end\\1")
  code.gsub!(/знач :=\s?/i, '')
  code.gsub!(/^(?:нач|кон)$/i, '')
  code.gsub!(/\s\=\s/, '==')
  code.gsub!(/^\s*цел ([a-z]+[a-z0-9_]*)\s?==\s?(.*?)\n/i, "\\1 = \\2\n")
  code.gsub!(/целтаб ([a-z]+[a-z_0-9]*)\[(.*):(.*)\]/i, "\\1 = []")
  code.gsub!(/^\s*цел (.*)/i) { |vars|
    $1.gsub(/([a-z]+[a-z0-9_]*),?/i, "\n\\1 = 0")
  }
  code.gsub!(/цел ([a-z_]+[a-z0-9_]*)/i, "\\1")
  code.gsub!(/^\s*вещ (.*)/i, "\\1 = 0.0")
  code.gsub!(/вещ ([a-z_]+[a-z0-9_]*)/i, "\\1.to_f")
  code.gsub!(/(.*):=(.*)\n/, "\\1=\\2\n")
  code.gsub!(/нц пока (.*)/i, "while \\1 do")
  code.gsub!(/нц для ([a-z]+) от ([a-z0-9]+) до ([a-z0-9]+)/i, "for \\1 in \\2..\\3 do")
  code.gsub!(/кц/i, 'end')
  
  ifelse = /если (.*?) то(.*?)все/im
  while code =~ ifelse do code.gsub!(ifelse, "if \\1 then\\2 end") end
  
  code.gsub!(/ввод ([a-z0-9,\s\[\]]+?)\n/i) { |vars|
    $1.gsub(/([a-z0-9\[\]]+),?/i, "\\1 = rl_pick()\n" )
  }
  code.gsub!(/'/, '"')
  
  code.gsub!(/вывод (.*)/i, "puts(\\1);")
  
  divmod! code
  code.downcase
end

# эта конструкция парсит вложенные див-моды изнутри наружу
def divmod! (code, div='/', mod='%')
  #func_rx = /([a-z_]+[a-z_0-9]*)\s?\(([a-z0-9_\s]+),([a-z0-9_\s]+)\)/i
  
  func_rx = /(div|mod)\s?\(([a-z0-9_\*\+\-\s\{\}\%\/\[\]]+),([a-z0-9_\*\+\-\s\{\}\%\/\[\]]+)\)/i
  escape_braces! code
  while code =~ func_rx
    code.gsub!(func_rx) { |match|
      sign = $1 == 'div' ? div : mod
    
      "((" + $2 + ") " + sign + " (" + $3 + "))"
    }
    escape_braces! code
  end 
  
  code.gsub!(/\{/, "(")
  code.gsub!(/\}/, ")")
  delete_lone_braces! (code)
end

def escape_braces! (code)
  braces = /\(([a-z0-9_\*\+\-\s\/\%\{\}\[\]]+)\)/i
  while code =~ braces
    code.gsub!(braces, "\{\\1\}")
  end
  code
end

def delete_lone_braces! (code)
  lone_braces = /([^a-z_0-9\s]\s*)\(\s*(-?[a-z0-9_\[\]]*)\s*\)/i
  while code =~ lone_braces
    code.gsub!(lone_braces, "\\1\\2")
  end
  code
end

@readline_pos = 0
def rl_pick
  begin
    STDIN.readline
  rescue
    @readline_pos+=1
    @readline_vals[@readline_pos-1]
  end
end

puts "="*10 + "АЛГ" + "="*10 + "\n"*2
puts code
puts "="*10 + "BASIC" + "="*10 + "\n"*2
puts toBasic code.clone
puts "="*10 + "PASCAL" + "="*10 + "\n"*2
puts toPascal code.clone
puts "="*10 + "C" + "="*10 + "\n"*2
puts toC code.clone
puts "="*10 + "Ruby" + "="*10 + "\n"*2
puts toRuby code.clone
puts "="*10 + "Result" + "="*10 + "\n"*2
eval toRuby code.clone
