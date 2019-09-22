unit mikko_consts_rus;

interface

resourcestring
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

const
  KODG_CLIENTSETIC = 27057; //Контрагенты по этикетке
implementation


end.
