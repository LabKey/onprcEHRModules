/**
 * User: Kolli
 * Date: 4/10/2020
 * Time: 10:36 AM
 */
EHR.model.DataModelManager.registerMetadata('ServiceRequestDetails', {
    allQueries: {
    },
    byQuery: {
        'study.IPC_ServiceRequestDetails': {

            project: {
                header:"Center Project",
                columnConfig: {
                    width: 150
                }
            },

            requestedBy: {
                header:"Requested By",
                columnConfig: {
                    width: 150
                }
            },

            email: {
                header:"Email",
                columnConfig: {
                    width: 150
                }
            },

            department: {
                header:"Department",
                columnConfig: {
                    width: 150
                }
            },

            pathologist: {
                xtype: 'combo',
                header:'Pathologist',
                hidden: false,
                lookup: {schemaName: 'study', queryName: 'IPC_Pathologist', displayColumn:'name' },

                editorConfig: {
                    listConfig: {
                        //innerTpl: '{[values.lastName + (values.firstName ? ", " + values.firstName : "")]}',
                        innerTpl: '{[(values.name)]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                },
                columnConfig: {
                    width: 200
                }
            },

            investigator: {
                xtype: 'combo',
                header: 'Investigator',
                hidden: false,
                lookup: {schemaName: 'study', queryName: 'IPC_Investigators', displayColumn: 'name'},
                editorConfig: {
                    listConfig: {
                        // innerTpl: '{[values.lastName + (values.firstName ? ", " + values.firstName : "")]}',
                        innerTpl: '{[(values.name)]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                },
                columnConfig: {
                    width: 200
                }
            },

            sampleLocation: {
                xtype: 'combo',
                header: 'Sample DropOff/PickUp Location',
                hidden: true,
                lookup: {schemaName: 'study', queryName: 'IPC_Locations', displayColumn: 'room'},

                editorConfig: {
                    listConfig: {
                        innerTpl: '{[(values.room)]}',
                        getInnerTpl: function(){
                            return this.innerTpl;
                        }
                    }
                },
                columnConfig: {
                    width: 200
                }
            }

        }

    }

});
