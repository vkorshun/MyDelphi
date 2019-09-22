unit mikko_consts;

interface

resourcestring
  {$IFDEF RES_ENGLISH}
  msg_ErrorNewNum     = 'Unsuccessful attempt to generate a unique code';
  msg_ErrorLockParoll = 'This user is already running!';
  msg_InvalidPassword = 'Invalid password!';
  msg_InvalidUsername = 'Invalid username!';
  msg_nullid          = 'Invalid unique key.'; //'Нулевой уникальный код'
  msg_RecordLocked    = 'Record is locked by another user'; // 'Запись заблокирована другим пользователем'
  msg_SearchCompleted = 'Search completed'; // Поиск завершен
  msg_SaveChanges     = ' Save changes?'; // Сохранить изм.
  msg_DeleteCurrentFile = 'Delete current file?';//'Удалить текущий файл?'
  msg_DeleteMail        =' Delete current mail? ';//'Удалить текущее письмо?'
  msg_CanEditOnlyOriginator = 'Only originator can edit this task ';// Задачу может редактировать только постановщик!'
  msg_ConfirmMarked   = 'Confirm marked?'; // Подтвердить помеченніе
  msg_UndefManager    = 'Not defined manager';//'Не указан менеджер!'
  msg_Deadlock        = 'Deadlock!' ;// 'Конфликт блокировок!'

  rs_Name         = 'Name';
  rs_Add          = 'New';
  rs_Edit         = 'Edit';
  rs_Delete       = 'Delete';
  rs_SearchString = 'Search string'; //'Строка поиска'
  rs_Find         = 'Find';
  rs_Continue     = 'Continue';
  rs_Up           = 'Up';
  rs_Down         = 'Down';
  rs_Save         = 'Save';
  rs_SetForm      = 'Form setting';//'Настройка формы';
  rs_Filter       = 'Filter';
  rs_refresh      = 'Refresh';

  rs_Date         = 'Date';
  rs_mFrom         = 'From'; //'Отправитель'
  rs_mTo           = 'To';   //'Получатель'
  rs_From         = 'From'; //'C..'
  rs_To           = 'To';   //'По..'
  rs_Attachments  = 'Attachments';
  rs_Manager      = 'Manager';//'Менеджер'
  rs_DateRange    = 'Date range';// Интервал дат

  rs_ClientForRange = 'Client for the date range';
  rs_ManagerForRange = 'Manager for the date range';
  rs_Confirmation    = 'Confirmation'; // Подтверждение
  rs_ToConfirm       = 'To confirmation';// На подпись
  rs_NotCompeted     = 'Not completed';//Не выполненные
  rs_CurrentMonth    = 'Current month';//Текущий месяц'
  rs_All             = 'All';
  rs_Mail            = 'Mail';
  rs_Files           = 'Files';
  rs_Status          = 'Status';
  rs_CompletionDate  = 'Completion date';//'Дата выполнения'
  rs_Priority        = 'Priority';
  rs_Client          = 'Client';
  rs_TargetDate      = 'Target date';
  rs_Comment         = 'Comment';
  rs_Originator      = 'Originator';
  {$ELSE}
  msg_ErrorNewNum     = 'Unsuccessful attempt to generate a unique code';
  msg_ErrorLockParoll = 'This user is already running!';
  msg_InvalidPassword = 'Invalid password!';
  msg_InvalidUsername = 'Invalid username!';
  msg_nullid          = 'Неверный уникальный код';
  msg_RecordLocked    = 'Запись заблокирована другим пользователем';
  msg_SearchCompleted = 'Поиск завершен';
  msg_SaveChanges     = ' Сохранить изминения ?';
  msg_DeleteCurrentFile = 'Удалить текущий файл?';
  msg_DeleteMail        ='Удалить текущее письмо?';
  msg_CanEditOnlyOriginator = ' Задачу может редактировать только постановщик!';
  msg_ConfirmMarked   =' Подтвердить помеченные ?';
  msg_UndefManager    = 'Не указан менеджер!';
  msg_Deadlock        = 'Конфликт блокировок!';

  rs_Name         = 'Наименование';
  rs_Add          = 'Ввол нового';
  rs_Edit         = 'Редактировать';
  rs_Delete       = 'Delete';
  rs_SearchString = 'Строка поиска';
  rs_Find         = 'Поиск';
  rs_Continue     = 'Продолжение поиска';
  rs_Up           = 'Вверх';
  rs_Down         = 'Вниз';
  rs_Save         = 'Сохранить';
  rs_SetForm      = 'Настройка формы';
  rs_Filter       = 'Фильтр';
  rs_refresh      = 'Обновить';

  rs_Date         = 'Дата';
  rs_mFrom         = 'Отправитель'; //'Отправитель'
  rs_mTo           = 'Получатель';
  rs_From         =  'C..';
  rs_To           =  'По..';
  rs_Attachments  =  'Attachments';
  rs_Manager      =  'Менеджер';
  rs_DateRange    =  'Интервал дат';

  rs_ClientForRange = 'Клиент за интервал дат';
  rs_ManagerForRange = 'Менеджер за интервал дат';
  rs_Confirmation    = 'Подтверждение'; // Подтверждение
  rs_ToConfirm       = 'На подпись';// На подпись
  rs_NotCompeted     = 'Не выполненные';//Не выполненные
  rs_CurrentMonth    = 'Текущий месяц';//Текущий месяц'
  rs_All             = 'Все';
  rs_Mail            = 'Почта';
  rs_Files           = 'Файлы';
  rs_Status          = 'Статус';
  rs_CompletionDate  = 'Дата выполнения';//'Дата выполнения'
  rs_Priority        = 'Приоритет';
  rs_Client          = 'Клиент';
  rs_TargetDate      = 'Дата постановки';
  rs_Comment         = 'Комментарий';
  rs_Originator      = 'Постановщик';

  {$ENDIF }

const
  KODG_CLIENTSETIC = 27057; //Контрагенты по этикетке
implementation


end.
