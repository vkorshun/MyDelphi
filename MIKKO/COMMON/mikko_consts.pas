unit mikko_consts;

interface

resourcestring
  {$IFDEF RES_ENGLISH}
  msg_ErrorNewNum     = 'Unsuccessful attempt to generate a unique code';
  msg_ErrorLockParoll = 'This user is already running!';
  msg_InvalidPassword = 'Invalid password!';
  msg_InvalidUsername = 'Invalid username!';
  msg_nullid          = 'Invalid unique key.'; //'������� ���������� ���'
  msg_RecordLocked    = 'Record is locked by another user'; // '������ ������������� ������ �������������'
  msg_SearchCompleted = 'Search completed'; // ����� ��������
  msg_SaveChanges     = ' Save changes?'; // ��������� ���.
  msg_DeleteCurrentFile = 'Delete current file?';//'������� ������� ����?'
  msg_DeleteMail        =' Delete current mail? ';//'������� ������� ������?'
  msg_CanEditOnlyOriginator = 'Only originator can edit this task ';// ������ ����� ������������� ������ �����������!'
  msg_ConfirmMarked   = 'Confirm marked?'; // ����������� ���������
  msg_UndefManager    = 'Not defined manager';//'�� ������ ��������!'
  msg_Deadlock        = 'Deadlock!' ;// '�������� ����������!'

  rs_Name         = 'Name';
  rs_Add          = 'New';
  rs_Edit         = 'Edit';
  rs_Delete       = 'Delete';
  rs_SearchString = 'Search string'; //'������ ������'
  rs_Find         = 'Find';
  rs_Continue     = 'Continue';
  rs_Up           = 'Up';
  rs_Down         = 'Down';
  rs_Save         = 'Save';
  rs_SetForm      = 'Form setting';//'��������� �����';
  rs_Filter       = 'Filter';
  rs_refresh      = 'Refresh';

  rs_Date         = 'Date';
  rs_mFrom         = 'From'; //'�����������'
  rs_mTo           = 'To';   //'����������'
  rs_From         = 'From'; //'C..'
  rs_To           = 'To';   //'��..'
  rs_Attachments  = 'Attachments';
  rs_Manager      = 'Manager';//'��������'
  rs_DateRange    = 'Date range';// �������� ���

  rs_ClientForRange = 'Client for the date range';
  rs_ManagerForRange = 'Manager for the date range';
  rs_Confirmation    = 'Confirmation'; // �������������
  rs_ToConfirm       = 'To confirmation';// �� �������
  rs_NotCompeted     = 'Not completed';//�� �����������
  rs_CurrentMonth    = 'Current month';//������� �����'
  rs_All             = 'All';
  rs_Mail            = 'Mail';
  rs_Files           = 'Files';
  rs_Status          = 'Status';
  rs_CompletionDate  = 'Completion date';//'���� ����������'
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
  msg_nullid          = '�������� ���������� ���';
  msg_RecordLocked    = '������ ������������� ������ �������������';
  msg_SearchCompleted = '����� ��������';
  msg_SaveChanges     = ' ��������� ��������� ?';
  msg_DeleteCurrentFile = '������� ������� ����?';
  msg_DeleteMail        ='������� ������� ������?';
  msg_CanEditOnlyOriginator = ' ������ ����� ������������� ������ �����������!';
  msg_ConfirmMarked   =' ����������� ���������� ?';
  msg_UndefManager    = '�� ������ ��������!';
  msg_Deadlock        = '�������� ����������!';

  rs_Name         = '������������';
  rs_Add          = '���� ������';
  rs_Edit         = '�������������';
  rs_Delete       = 'Delete';
  rs_SearchString = '������ ������';
  rs_Find         = '�����';
  rs_Continue     = '����������� ������';
  rs_Up           = '�����';
  rs_Down         = '����';
  rs_Save         = '���������';
  rs_SetForm      = '��������� �����';
  rs_Filter       = '������';
  rs_refresh      = '��������';

  rs_Date         = '����';
  rs_mFrom         = '�����������'; //'�����������'
  rs_mTo           = '����������';
  rs_From         =  'C..';
  rs_To           =  '��..';
  rs_Attachments  =  'Attachments';
  rs_Manager      =  '��������';
  rs_DateRange    =  '�������� ���';

  rs_ClientForRange = '������ �� �������� ���';
  rs_ManagerForRange = '�������� �� �������� ���';
  rs_Confirmation    = '�������������'; // �������������
  rs_ToConfirm       = '�� �������';// �� �������
  rs_NotCompeted     = '�� �����������';//�� �����������
  rs_CurrentMonth    = '������� �����';//������� �����'
  rs_All             = '���';
  rs_Mail            = '�����';
  rs_Files           = '�����';
  rs_Status          = '������';
  rs_CompletionDate  = '���� ����������';//'���� ����������'
  rs_Priority        = '���������';
  rs_Client          = '������';
  rs_TargetDate      = '���� ����������';
  rs_Comment         = '�����������';
  rs_Originator      = '�����������';

  {$ENDIF }

const
  KODG_CLIENTSETIC = 27057; //����������� �� ��������
implementation


end.
