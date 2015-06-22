#Include <DBA>
connectionString := "Server=192.168.0.140;Database=claims_tracking;Port=3306;Uid=root;Pwd=4112"
try
{
	db := DBA.DataBaseFactory.OpenDataBase("MySQL", connectionString)
} catch e {
	MsgBox, 8208, Tracking Manager, Looks like the server is down. Please notify your administrator
	ExitApp
}