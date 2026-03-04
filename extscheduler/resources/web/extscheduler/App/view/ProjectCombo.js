
Ext.define('App.view.ProjectCombo', {
    extend       : 'Ext.form.field.ComboBox',
    alias        : 'widget.projectcombo',
    store        : 'projectst',
    queryMode    : 'local',
    valueField   : 'project',
    displayField : 'displayName',
    editable     : false
});