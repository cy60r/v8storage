
#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать v8runner
#Использовать json

Перем Лог;
Перем ЭтоWindows;
Перем КаталогХранилища;
Перем УправлениеКонфигураторомХранилища;
Перем ПараметрыАвторитизации;
Перем ТаблицаВерсий;
Перем МассивАвторов;
Перем ПарсерJSON;
Перем ПутьКОбработкеКонвертации;
Перем ЧтениеХранилищаВыполнено;
Перем ОбработкаКонвертацииОтчетаСобрана;

// Установка каталога файлового хранилища конфигурации
//
// Параметры:
//   НовыйКаталогХранилища - Строка - путь к папке с хранилищем конфигурации 1С
//
Процедура УстановитьКаталогХранилища(Знач НовыйКаталогХранилища) Экспорт
    КаталогХранилища = НовыйКаталогХранилища;
КонецПроцедуры

// Установка авторитизации в хранилище конфигурации
//
// Параметры:
//   Пользователь - Строка - пользователь хранилищем конфигурации 1С
//   Пароль - Строка - пароль пользователя хранилищем конфигурации 1С (по умолчанию пустая строка)
//
Процедура УстановитьПараметрыАвторитизации(Знач Пользователь, Знач Пароль = "") Экспорт
	
    ПараметрыАвторитизации.Вставить("Пользователь", Пользователь);
    ПараметрыАвторитизации.Вставить("Пароль", Пароль);
    
КонецПроцедуры

// Установка управления конфигуратором в класс менеджер хранилища конфигурации
//
// Параметры:
//   НовыйУправлениеКонфигуратором - класс - инстанс класс УправлениеКонфигуратором из библиотеке v8runner
//
Процедура УстановитьУправлениеКонфигуратором(НовыйУправлениеКонфигуратором) Экспорт

    УправлениеКонфигураторомХранилища = НовыйУправлениеКонфигуратором;
    
КонецПроцедуры

// Сохранение в файл версии конфигурации из хранилища
//
// Параметры:
//   НомерВерсии - число/строка - номер версии в хранилище
//   ИмяФайлаКофигурации - строка - путь к файлу в который будет сохранена версия конфигурации из хранилища 
//
Процедура СохранитьВерсиюКонфигурацииВФайл(Знач НомерВерсии, Знач ИмяФайлаКофигурации) Экспорт

    Параметры = СтандартныеПараметрыЗапуска();

	Параметры.Добавить(СтрШаблон("/ConfigurationRepositoryDumpCfg ""%1""", ИмяФайлаКофигурации));

	Если Не ПустаяСтрока(НомерВерсии) Тогда
		Параметры.Добавить("-v "+НомерВерсии);
	КонецЕсли;

	УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Сохранение в файл последней версии конфигурации из хранилища
// (обертка над процедурой "СохранитьВерсиюКонфигурацииВФайл")
// Параметры:
//   ИмяФайлаКофигурации - строка - путь к файлу в который будет сохранена версия конфигурации из хранилища 
//
Процедура ПоследняяВерсияКонфигурацииВФайл(Знач ИмяФайлаКофигурации) Экспорт

   СохранитьВерсиюКонфигурацииВФайл("", ИмяФайлаКофигурации);

КонецПроцедуры

// Чтение данных по истории версий и авторов из хранилища
// 
// Параметры:
//   НомерНачальнойВерсии - число - номер версии хранилища, 
//                                  с которой производиться получение истории (по умолчанию 1) 
//   
Процедура ПрочитатьХранилище(Знач НомерНачальнойВерсии = 1) Экспорт

    ПутьКФайлуОтчета = ВременныеФайлы.НовоеИмяФайла("mxl");
    ПутьКФайлуОтчетаJSON = ВременныеФайлы.НовоеИмяФайла("json");
    
    ПолучитьОтчетПоВерсиям(ПутьКФайлуОтчета, НомерНачальнойВерсии);
    СконвертироватьОтчет(ПутьКФайлуОтчета, ПутьКФайлуОтчетаJSON);
      
    ТекстJSON = ПрочитатьФайл(ПутьКФайлуОтчетаJSON);
    Результат = ПарсерJSON.ПрочитатьJSON(ТекстJSON);

    МассивАвторов = Результат["Авторы"];
    ПрочитатьТаблицуВерсий(Результат["Версии"]);

    ЧтениеХранилищаВыполнено = Истина;

КонецПроцедуры

// Получение таблицы истории версий из хранилища
// (выполняет ПрочитатьХранилище(1), если еще не было чтения)
//
// Возвращаемое значение таблица значений:
//   Колонки: 
//      Номер   - число - номер версии  
//      Дата    - Дата - Дата версии  
//      Автор   - строка - автор версии  
//      Комментарий   - Строка - многострочная строка с комментарием к версии  
// 
Функция ПолучитьТаблицуВерсий() Экспорт
    
    ПроверитьЗагрузкуДанныхХранилища();

    Возврат ТаблицаВерсий;    


КонецФункции // ПолучитьТаблицуВерсий() Экспорт

// Получение массива авторов версий из хранилища
// (выполняет ПрочитатьХранилище(1), если еще не было чтения)
// 
// Возвращаемое значение массив:
//      Автор - строка - используемые авторы в хранилище  
// 
Функция ПолучитьАвторов() Экспорт
    
    ПроверитьЗагрузкуДанныхХранилища();

    Возврат МассивАвторов;    


КонецФункции // ПолучитьТаблицаВерсий() Экспорт

// Получение отчет по истории версий  из хранилища
// 
// Параметры:
//   ПутьКФайлуРезультата - Строка - путь к файлу в который будет выгружен отчет, 
//   НомерНачальнойВерсии - число - номер начальной версии хранилища,
//                                  с которой производиться получение истории (по умолчанию 1) 
//   НомерКонечнойВерсии  - число - номер конечной версии хранилища. (по умолчанию - Неопределено)
//                                    
Процедура ПолучитьОтчетПоВерсиям(Знач ПутьКФайлуРезультата,
                                Знач НомерНачальнойВерсии = 1,
                                Знач НомерКонечнойВерсии = Неопределено) Экспорт
    
    Параметры = СтандартныеПараметрыЗапуска();
    
    Параметры.Добавить("/ConfigurationRepositoryReport """+ПутьКФайлуРезультата + """");

	Параметры.Добавить("-NBegin "+НомерНачальнойВерсии);

	Если ЗначениеЗаполнено(НомерКонечнойВерсии) Тогда
    
        Параметры.Добавить("-NEnd "+НомерКонечнойВерсии);

    КонецЕслИ;

    УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);
    
КонецПроцедуры

// Выполняет подключение ранее неподключенной информационной базы к хранилищу конфигурации.
//
// Параметры:
//  ИгнорироватьНаличиеПодключеннойБД  - Булево - Флаг игнорирования наличия уже у пользователя уже подключенной базы данных. По умолчанию = Ложь
//								 	 Выполняет подключение даже в том случае, если для данного пользователя уже есть конфигурация, связанная с данным хранилищем..
//  ЗаменитьКонфигурациюБД - Булево - Флаг замены конфигурации БД на конфигурацию хранилища  (По умолчанию Истина)
//									 Если конфигурация непустая, данный ключ подтверждает замену конфигурации на конфигурацию из хранилища.
//
Процедура ПодключитьсяКХранилищу(Знач ИгнорироватьНаличиеПодключеннойБД = Ложь, Знач ЗаменитьКонфигурациюБД = Истина) Экспорт
    
    Если Не ЗначениеЗаполнено(КаталогХранилища) Тогда
        ВызватьИсключение "Не установлен каталог хранилища 1С";
    КонецЕсли;

    Параметры = СтандартныеПараметрыЗапуска();

    Параметры.Добавить("/ConfigurationRepositoryBindCfg ");
  
    Если ИгнорироватьНаличиеПодключеннойБД Тогда
        Параметры.Добавить("-forceBindAlreadyBindedUser ");
    КонецЕсли;
    Если ЗаменитьКонфигурациюБД Тогда
        Параметры.Добавить("-forceReplaceCfg ");
    КонецЕсли;		
	
	УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

КонецПроцедуры

// Получение отчет по истории версий  из хранилища
// 
// Параметры:
//   ПутьКФайлуРезультата - Строка - путь к файлу отчета в формате mxl 
//   ПутьКФайлуОтчетаJSON - Строка - путь к файлу в который будет выгружен отчет в формате json,
//                                    
Процедура СконвертироватьОтчет(Знач ПутьКФайлуОтчета, Знач ПутьКФайлуОтчетаJSON) Экспорт

    КлючЗапуска = СтрШаблон("""%1;%2""", ПутьКФайлуОтчета, ПутьКФайлуОтчетаJSON);
    ПараметрыЗапускаОбработки = СтрШаблон("/Execute ""%1""", ПолучитьОбработкуКонвертацииОтчета());
    УправлениеКонфигураторомХранилища.ЗапуститьВРежимеПредприятия(КлючЗапуска, Ложь, ПараметрыЗапускаОбработки);
        
КонецПроцедуры


Процедура ПроверитьЗагрузкуДанныхХранилища()

    Если Не ЧтениеХранилищаВыполнено Тогда
       ПрочитатьХранилище();
    КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьТаблицуВерсий(Знач МассивВерсий)

    ТаблицаВерсий = Новый ТаблицаЗначений;
    ТаблицаВерсий.Колонки.Добавить("Номер");
    ТаблицаВерсий.Колонки.Добавить("Дата");
    ТаблицаВерсий.Колонки.Добавить("Автор");
    ТаблицаВерсий.Колонки.Добавить("Комментарий");

    Для Каждого ВерсияМассива из МассивВерсий Цикл

         НоваяСтрока = ТаблицаВерсий.Добавить();   
         НоваяСтрока.Номер = ВерсияМассива["Номер"];
         НоваяСтрока.Дата = ВерсияМассива["Дата"];
         НоваяСтрока.Автор = ВерсияМассива["Автор"];
         НоваяСтрока.Комментарий = ВерсияМассива["Комментарий"];
         
    КонецЦикла
    
КонецПроцедуры

Функция ПрочитатьФайл(ПутьКФайлу)
    
    
    ЧтениеТекстаФайла = Новый ЧтениеТекста(ПутьКФайлу, "utf-8");
    
    Текст = ЧтениеТекстаФайла.Прочитать();
    
    ЧтениеТекстаФайла.Закрыть();
    
    Если ПустаяСтрока(Текст) Тогда
        
        ВызватьИсключение "Из файла ничего не прочитано"
        
    Иначе
        
        Возврат Текст;
        
    КонецЕсли;
    
КонецФункции

Функция ПолучитьОбработкуКонвертацииОтчета()
    
    Если НЕ ОбработкаКонвертацииОтчетаСобрана Тогда
        
        СобратьОбработкуКонвертацииОтчета();

    КонецЕсли;
    
    Возврат ПутьКОбработкеКонвертации;

КонецФункции

Процедура СобратьОбработкуКонвертацииОтчета()
    
   
    ПутьКОбработкеКонвертации = ВременныеФайлы.НовоеИмяФайла("epf");
    
    СобратьОбработкуКонвертации(ОбъединитьПути(ТекущийСценарий().Каталог,"../ОбработкаКонвертацииMXLJSON/ОбработкаКонвертацииMXLJSON.xml"), ПутьКОбработкеКонвертации);

    ОбработкаКонвертацииОтчетаСобрана = Истина;
    
КонецПроцедуры

Функция СтандартныеПараметрыЗапуска()
    
    ПараметрыЗапуска = УправлениеКонфигураторомХранилища.ПолучитьПараметрыЗапуска();
    
    Если Не ПустаяСтрока(ПараметрыАвторитизации.Пользователь) Тогда
		 ПараметрыЗапуска.Добавить(СтрШаблон("/ConfigurationRepositoryN ""%1""", ПараметрыАвторитизации.Пользователь));
    КонецЕсли;

    Если Не ПустаяСтрока(ПараметрыАвторитизации.Пароль) Тогда
		 ПараметрыЗапуска.Добавить(СтрШаблон("/ConfigurationRepositoryP ""%1""", ПараметрыАвторитизации.Пароль));
    КонецЕсли;

    Если Не ПустаяСтрока(КаталогХранилища) Тогда
		 ПараметрыЗапуска.Добавить(СтрШаблон("/ConfigurationRepositoryF ""%1""", КаталогХранилища));
    КонецЕсли;

    Возврат ПараметрыЗапуска;
КонецФункции // СтандартныеПараметрыЗапуска()

Процедура Инициализация()
    
    Лог = Логирование.ПолучитьЛог("oscript.lib.v8storage");
    ПараметрыАвторитизации = Новый Структура();
    УправлениеКонфигураторомХранилища = Новый УправлениеКонфигуратором();
    ВременныйКаталог = ВременныеФайлы.СоздатьКаталог();
    УправлениеКонфигураторомХранилища.КаталогСборки(ВременныйКаталог);
    УправлениеКонфигураторомХранилища.УстановитьКодЯзыкаСеанса("ru");
    ОбработкаКонвертацииОтчетаСобрана = Ложь; 
   
    СистемнаяИнформация = Новый СистемнаяИнформация;
    ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;
    ПарсерJSON = Новый ПарсерJSON();
	ЧтениеХранилищаВыполнено = Ложь; 

КонецПроцедуры

Процедура СобратьОбработкуКонвертации(Знач ПапкаИсходников, Знач ИмяФайлаОбъекта)

	Лог.Отладка("Собираю файл из исходников <%1> в файл %2", ПапкаИсходников, ИмяФайлаОбъекта);
    Лог.Отладка("");
 
 	Параметры = УправлениеКонфигураторомХранилища.ПолучитьПараметрыЗапуска();
 
 	Параметры.Добавить("/LoadExternalDataProcessorOrReportFromFiles");
 	Параметры.Добавить(СтрШаблон("""%1""", ПапкаИсходников));
 	Параметры.Добавить(СтрШаблон("""%1""", ИмяФайлаОбъекта));
 	
 	УправлениеКонфигураторомХранилища.ВыполнитьКоманду(Параметры);

 	Лог.Отладка("Вывод 1С:Предприятия - " + УправлениеКонфигураторомХранилища.ВыводКоманды());
	Лог.Отладка("");

КонецПроцедуры


Инициализация();