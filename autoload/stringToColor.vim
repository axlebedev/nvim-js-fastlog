vim9script

def GetArrayFromString(str: string, p: number): list<number>
    var res = []
    var i = p
    while i < str->len()
        res->add(char2nr(str[i]))
        i += 3
    endwhile
    return res
enddef

def GetArraySum(arr: list<number>): number
    var acc = 0
    for i in arr
        acc += i
    endfor
    return acc
enddef

# vim9-скрипту не нравится, когда в map-функции я возвращаю string
# Поэтому пришлось это сделать вручную
def GentleMap(arr: list<number>): list<string>
    var min = arr->min()
    var max = arr->max() - min
    var res = []
    for i in arr
        var val = max == 0 ? i : (i - min) * 255 / max
        var hexstr = printf('%x', val)
        var newItem = hexstr->len() == 1 ? '0' .. hexstr : hexstr
        res->add(newItem)
    endfor
    return res
enddef

export def StringToColor(strArg: string): string
    var str = strArg->split('/')[-2 : ]->join('')
    var numbersRedArray = GetArrayFromString(str, 0)
    var numbersGreenArray = GetArrayFromString(str, 1)
    var numbersBlueArray = GetArrayFromString(str, 2)

    var unnormR = GetArraySum(numbersRedArray) / numbersRedArray->len()
    var unnormG = GetArraySum(numbersGreenArray) / numbersGreenArray->len()
    var unnormB = GetArraySum(numbersBlueArray) / numbersBlueArray->len()

    var unnormArr = [unnormR, unnormG, unnormB]
    var arr = GentleMap(unnormArr)
    return '#' .. arr->join('')
enddef
