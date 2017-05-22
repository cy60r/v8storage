
#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать v8runner
#Использовать strings

Перем Лог;
Перем ЭтоWindows;
Перем мРабочийКаталог;


// 1. Получение истории хранилища конфигурации (коммитов)
// 2. Получение версии cf
// 3. Коммит в хранилище конфигурации 1С
// 4. Получение таблицы авторов и тегов записей истории 


Процедура УстановитьРабочийКаталог()
	
КонецПроцедуры

Процедура УстановитьРежимРаботы(Знач РежимРаботыСХранилищей)
	
КонецПроцедуры


////
// ПОЛУЧЕНИЕ ВЕРСИЙ ИЗ Хранилища

Функция СохранитьВерсиюКонфигурации(Знач НомерВерсии) Экспорт
	
	ИмяФайлаКофигурации = "";


	Возврат ИмяФайлаКофигурации;

КонецФункции

Процедура СохранитьВерсиюКонфигурацииВФайл(Знач НомерВерсии, Знач ИмяФайлаКофигурации) Экспорт


	
КонецПроцедуры


// Выполняет чтение таблицы VERSIONS из хранилища 1С
//
// Возвращаемое значение: ТаблицаЗначений
//
Функция ПрочитатьТаблицуИсторииХранилища(Знач ФайлХранилища) Экспорт

	ЧтениеБазыДанных = Новый ЧтениеТаблицФайловойБазыДанных;
	ЧтениеБазыДанных.ОткрытьФайл(ФайлХранилища);
	Попытка
		ТаблицаБД = ЧтениеБазыДанных.ПрочитатьТаблицу("VERSIONS");
	Исключение
		ЧтениеБазыДанных.ЗакрытьФайл();
		ВызватьИсключение;
	КонецПопытки;

	ЧтениеБазыДанных.ЗакрытьФайл();

	ТаблицаВерсий = КонвертироватьТаблицуВерсийИзФорматаБД(ТаблицаБД);
	ТаблицаВерсий.Сортировать("НомерВерсии");

	Возврат ТаблицаВерсий;

КонецФункции

// Считывает таблицу USERS пользователей хранилища
//
Функция ПрочитатьТаблицуПользователейХранилища(Знач ФайлХранилища) Экспорт

	ЧтениеБазыДанных = Новый ЧтениеТаблицФайловойБазыДанных;
	ЧтениеБазыДанных.ОткрытьФайл(ФайлХранилища);
	Попытка
		ТаблицаБД = ЧтениеБазыДанных.ПрочитатьТаблицу("USERS");
	Исключение
		ЧтениеБазыДанных.ЗакрытьФайл();
		ВызватьИсключение;
	КонецПопытки;

	ЧтениеБазыДанных.ЗакрытьФайл();

	Возврат ТаблицаБД;


КонецФункции


/////////////////////////////////////////
// РАЗБОРКА конфигурации на исходники

// ОСНОВНАЯ ПРОЦЕДУРА РАЗБОРА
// Разбирает конфигурацию файла на исходники
// 1. Создает временную базу данных с указанной конфигурацией
// 2. Вызывает разбор конфигурации на исходники для базы данных 
Процедура РазобратьФайлКонфигурации(Знач ФайлКонфигурации, Знач ВыходнойКаталог, Знач ВерсияПлатформы="") Экспорт

    ОбъектФайл = Новый Файл(ФайлКонфигурации);
    Если ОбъектФайл.Существует() = Ложь Тогда
        ВызватьИсключение СтроковыеФункции.ПодставитьПараметрыВСтроку("Файл конфигурации %1 не найден", ОбъектФайл.ПолноеИмя);
    КонецЕсли;

    КаталогПлоскойВыгрузки = ВременныеФайлы.СоздатьКаталог();
    
    КаталогВыгрузки = Новый Файл(ВыходнойКаталог); 
    Если КаталогВыгрузки.Существует() = Ложь Тогда
        СоздатьКаталог(ВыходнойКаталог);
    КонецЕсли;
    
    Конфигуратор = Новый УправлениеКонфигуратором();
    КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
    Конфигуратор.КаталогСборки(КаталогВременнойИБ);
    
    Если Не ПустаяСтрока(ВерсияПлатформы) Тогда 
        Конфигуратор.ИспользоватьВерсиюПлатформы(ВерсияПлатформы);
    КонецЕсли;
    
    Конфигуратор.ЗагрузитьКонфигурациюИзФайла(ФайлКонфигурации, Ложь);
            
    РазобратьНаИсходникиКонфигурациюБазыДанны(ВыходнойКаталог, Конфигуратор.ПолучитьПараметрыЗапуска().Получить(1));
    
    ВременныеФайлы.УдалитьФайл(КаталогПлоскойВыгрузки);
    ВременныеФайлы.УдалитьФайл(КаталогВременнойИБ);

КонецПроцедуры

Функция УбратьКавычкиВокругПути(Путь)
    //NOTICE: https://github.com/xDrivenDevelopment/precommit1c 
    //Apache 2.0 
    ОбработанныйПуть = Путь;

    Если Лев(ОбработанныйПуть, 1) = """" Тогда
        ОбработанныйПуть = Прав(ОбработанныйПуть, СтрДлина(ОбработанныйПуть) - 1);
    КонецЕсли;
    Если Прав(ОбработанныйПуть, 1) = """" Тогда
        ОбработанныйПуть = Лев(ОбработанныйПуть, СтрДлина(ОбработанныйПуть) - 1);
    КонецЕсли;
    
    Возврат ОбработанныйПуть;
    
КонецФункции



Процедура Инициализация()
    
    Лог = Логирование.ПолучитьЛог("oscript.lib.v8storage");
    
    СистемнаяИнформация = Новый СистемнаяИнформация;
    ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
           
КонецПроцедуры

Инициализация();