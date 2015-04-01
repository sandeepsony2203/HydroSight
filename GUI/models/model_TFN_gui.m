classdef model_TFN_gui < model_gui_abstract
    %MODEL_TFN_GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % NOTE: Inputs from the parent table are define in abstract
        %  
        % Model specific GUI properties.
        forcingTranforms
        weightingFunctions
        derivedForcingTranforms
        derivedWeightingFunctions
        modelComponants
        modelOptions 
        
        % Current active main table, row, col
        currentSelection;

        % Copied table rows
        copiedData;
    end
    
    methods
        %% Build the GUI for this model type.
        function this = model_TFN_gui(parent_handle)
            
            % Initialise properties not initialised below
            this.boreID = [];
            this.siteData = [];
            this.forcingData = [];  
            this.currentSelection.table = '';            
            this.currentSelection.row = 0;
            this.currentSelection.col = 0;
            
            % Get the available modle options
            %--------------------------------------------------------------
            % Get the types of weighting function and derived weighting function
            if ~isdeployed
                display('DBG: App is not deployed');
                warning('off');
                forcingFunctions = findClassDefsUsingAbstractName( 'forcingTransform_abstract', 'model_TFN');
                derivedForcingFunctions = findClassDefsUsingAbstractName( 'derivedForcingTransform_abstract', 'model_TFN');

                % Get the types of weighting function and derived weighting function
                weightFunctions = findClassDefsUsingAbstractName( 'responseFunction_abstract', 'model_TFN');
                derivedWeightFunctions = findClassDefsUsingAbstractName( 'derivedResponseFunction_abstract', 'model_TFN');
                warning('on');
            else
                % Hard code in function names if the code is deployed. This
                % is required because depfun does not dunction in deployed
                % code.                
                forcingFunctions = {'climateTransform_soilMoistureModels'};                
                derivedForcingFunctions = {'derivedForcing_linearUnconstrainedScaling'};                
                derivedWeightFunctions = {  'derivedResponseFunction_abstract', ...
                                            'derivedweighting_PearsonsNegativeRescaled', ...
                                            'derivedweighting_PearsonsPositiveRescaled'};
                weightFunctions = {         'responseFunction_abstract', ...
                                            'responseFunction_Bruggeman', ...
                                            'responseFunction_FerrisKnowles', ...
                                            'responseFunction_FerrisKnowlesJacobs', ...
                                            'responseFunction_Hantush', ...
                                            'responseFunction_JacobsCorrection', ...
                                            'responseFunction_Pearsons', ...
                                            'responseFunction_PearsonsNegative'};
            end
                

            % Forcing function column headings etc
            cnames_forcing = {'Select','Forcing Transform Function','Input Data', 'Options'};
            cformats_forcing = {'logical',forcingFunctions,'char','char'};
            cedit_forcing = logical([1 1 1 1]);
            rnames_forcing = {'1'};
            cdata_forcing = cell(1,4);
            toolTip_forcing = ['<html>This table (optional) allows the transformation of the input forcing data (e.g. rainfall to recharge). <br>', ...
                          'Below are tips for the table:<br>', ... 
                          '<ul type="bullet type">', ...
                          '<li>Different functions can be selected for the transformation.', ...
                          '<li>The transformed forcing data is selected in step 2 or 4 (not in this step).', ...
                          '<li>The function name and input forcing data must be defined.', ...
                          '<li>Some functions require additional setting. These will be displayed in a lower box when required.', ...
                          '<li><b>Right-click</b> displays a menu for copying, pasting, inserting and deleting rows. Use the <br>', ...
                          'left tick-box to define the rows for copying, deleting etc.<br>', ...
                          '<li>Sort the rows by clicking on the column headings. Below are more complex sorting options:<ul>', ...
                          '      <li><b>Click</b> to sort in ascending order.<br>', ...
                          '      <li><b>Shift-click</b> to sort in descending order.<br>', ...    
                          '      <li><b>Ctrl-click</b> to sort secondary in ascending order.<b>Shift-Ctrl-click</b> for descending order.<br>', ...    
                          '      <li><b>Click again</b> again to change sort direction.<br>', ...
                          '      <li><b>Click a third time </b> to return to the unsorted view.', ...
                          ' </ul></ul></html>'];                          
            
            % Derived forcing function column headings etc
            cnames_forcingDerived = {'Select','Forcing Transform Function','Source Forcing Function','Input Data', 'Options'};
            cformats_forcingDerived = {'logical',derivedForcingFunctions,{'(No functions available)'},'char','char'};    
            cedit_forcingDerived = logical([1 1 1 1 1]);
            rnames_forcingDerived = {'1'};
            cdata_forcingDerived = cell(1,5);
            toolTip_forcingDerived = ['<html>This table (optional) allows the transformation of transformed forcing data <br>', ...
                          'using a previously defined transformation function output as an input to this function. This allows,<br>', ...
                          'for example, the simulation of landuse change altering the recharge or phreatic ET.<br>', ...
                          'Below are tips for the table:<br>', ... 
                          '<ul type="bullet type">', ...
                          '<li>Different functions can be selected for the transformation.', ...
                          '<li>The transformed forcing data is selected in step 2 or 4 (not in this step).', ...
                          '<li>The transformation function name, source function and input forcing data must be defined.', ...
                          '<li>Some functions require additional setting. These will be displayed in a lower box when required.', ...
                          '<li><b>Right-click</b> displays a menu for copying, pasting, inserting and deleting rows. Use the <br>', ...
                          'left tick-box to define the rows for copying, deleting etc.<br>', ...
                          '<li>Sort the rows by clicking on the column headings. Below are more complex sorting options:<ul>', ...
                          '      <li><b>Click</b> to sort in ascending order.<br>', ...
                          '      <li><b>Shift-click</b> to sort in descending order.<br>', ...    
                          '      <li><b>Ctrl-click</b> to sort secondary in ascending order.<b>Shift-Ctrl-click</b> for descending order.<br>', ...    
                          '      <li><b>Click again</b> again to change sort direction.<br>', ...
                          '      <li><b>Click a third time </b> to return to the unsorted view.', ...
                          ' </ul></ul></html>'];                          
            
            % Weighting function column headings etc
            cnames_weighting = {'Select','Component Name','Weighting Function','Input Data', 'Options'};
            cformats_weighting = {'logical','char', weightFunctions,'char','char'};
            cedit_weighting = logical([1 1 1 1 1]);
            rnames_weighting = {'1'};
            cdata_weighting = cell(1,5);
            toolTip_weighting = ['<html>This table (required) allows the weighting of forcing data (e.g. rainfall, recharge or pumping). <br>', ...
                          'into a groundwater head change. Below are tips for the table:<br>', ... 
                          '<ul type="bullet type">', ...
                          '<li>Each component must be given a name e.g. pumping.',...
                          '<li>A range of weighting functions can be selected.', ...
                          '<li>Transformed forcing data from step 1 can be selected.', ...
                          '<li>The component name and forcing data must be defined.', ...
                          '<li>Some functions require additional setting. These will be displayed in a lower box when required.', ...
                          '<li><b>Right-click</b> displays a menu for copying, pasting, inserting and deleting rows. Use the <br>', ...
                          'left tick-box to define the rows for copying, deleting etc.<br>', ...
                          '<li>Sort the rows by clicking on the column headings. Below are more complex sorting options:<ul>', ...
                          '      <li><b>Click</b> to sort in ascending order.<br>', ...
                          '      <li><b>Shift-click</b> to sort in descending order.<br>', ...    
                          '      <li><b>Ctrl-click</b> to sort secondary in ascending order.<b>Shift-Ctrl-click</b> for descending order.<br>', ...    
                          '      <li><b>Click again</b> again to change sort direction.<br>', ...
                          '      <li><b>Click a third time </b> to return to the unsorted view.', ...
                          ' </ul></ul></html>'];                          

            
            % Derived Weighting function column headings etc
            cnames_weightingDerived = {'Select','Component Name','Weighting Function','Source Component','Input Data', 'Options'};
            cformats_weightingDerived = {'logical','char', derivedWeightFunctions,'char','char','char'};    
            cedit_weightingDerived = logical([1 1 1 1 1 1]);
            rnames_weightingDerived = {'1'};
            cdata_weightingDerived = cell(1,6);
            toolTip_weightingDerived = ['<html>This table (optional) allows weighting of forcing data (e.g. rainfall, recharge or pumping). <br>', ...
                          'using a previously defined weighting function. This allows, for example, the simulation of<br>', ...
                          'evaporative drawdown or landuse change by only the re-scaling of a previously defined weighting<br>', ...
                          'function (such the Pearsons Function). Below are tips for the table:<br>', ... 
                          '<ul type="bullet type">', ...
                          '<li>Each derived weighting function component must be given a name e.g. Phreatic_ET.', ...
                          '<li>A range of derived weighting functions can be selected.', ...
                          '<li>Transformed forcing data from step 1 and 3 can be selected.', ...
                          '<li>The component name, source weighting function and forcing data must be defined.', ...
                          '<li>Some functions require additional setting. These will be displayed in a lower box when required.', ...
                          '<li><b>Right-click</b> displays a menu for copying, pasting, inserting and deleting rows. Use the <br>', ...
                          'left tick-box to define the rows for copying, deleting etc.<br>', ...
                          '<li>Sort the rows by clicking on the column headings. Below are more complex sorting options:<ul>', ...
                          '      <li><b>Click</b> to sort in ascending order.<br>', ...
                          '      <li><b>Shift-click</b> to sort in descending order.<br>', ...    
                          '      <li><b>Ctrl-click</b> to sort secondary in ascending order.<b>Shift-Ctrl-click</b> for descending order.<br>', ...    
                          '      <li><b>Click again</b> again to change sort direction.<br>', ...
                          '      <li><b>Click a third time </b> to return to the unsorted view.', ...
                          ' </ul></ul></html>'];                          
            
            % Create the GUI elements
            %--------------------------------------------------------------
            % Create grid the model settings            
            %this.Figure = uiextras.HBoxFlex('Parent',parent_handle,'Padding', 3, 'Spacing', 3);
            this.Figure = uiextras.VBoxFlex('Parent',parent_handle,'Padding', 3, 'Spacing', 3);
            
            % Add box for the four model settings sub-boxes
            this.modelComponants = uiextras.GridFlex('Parent', this.Figure,'Padding', 3, 'Spacing', 3);                                    
            
            % Build the forcing transformation settings items
            this.forcingTranforms.vbox = uiextras.Grid('Parent', this.modelComponants,'Padding', 3, 'Spacing', 3);
            this.forcingTranforms.lbl = uicontrol( 'Parent', this.forcingTranforms.vbox,'Style','text','String','1. Forcing Transform Function (optional)','Visible','on');
            this.forcingTranforms.tbl = uitable('Parent',this.forcingTranforms.vbox,'ColumnName',cnames_forcing,...
                'ColumnEditable',cedit_forcing,'ColumnFormat',cformats_forcing,'RowName',...
                rnames_forcing ,'Data',cdata_forcing, 'Visible','on', 'Units','normalized', ...
                'CellSelectionCallback', @this.tableSelection, ...
                'CellEditCallback', @this.tableEdit, ...
                'Tag','Forcing Transform', ...
                'TooltipString',toolTip_forcing);
            
            set( this.forcingTranforms.vbox, 'ColumnSizes', -1, 'RowSizes', [35 -1] );

            % Find java sorting object in table
            jscrollpane = findjobj(this.forcingTranforms.tbl);
            jtable = jscrollpane.getViewport.getView;

            % Turn the JIDE sorting on
            jtable.setSortable(true);
            jtable.setAutoResort(true);
            jtable.setMultiColumnSortable(true);
            jtable.setPreserveSelectionsAfterSorting(true);            
                                    
            % Build the derived  forcing transformation settings items
            this.derivedForcingTranforms.vbox = uiextras.Grid('Parent', this.modelComponants,'Padding', 3, 'Spacing', 3);
            this.derivedForcingTranforms.lbl = uicontrol( 'Parent', this.derivedForcingTranforms.vbox,'Style','text','String','3. Derived Forcing Transform Function (optional)','Visible','on');
            this.derivedForcingTranforms.tbl = uitable('Parent',this.derivedForcingTranforms.vbox,'ColumnName',cnames_forcingDerived, ...
                'ColumnEditable',cedit_forcingDerived,'ColumnFormat',cformats_forcingDerived,'RowName',...
                rnames_forcingDerived ,'Data',cdata_forcingDerived, 'Visible','on', 'Units','normalized', ...
                'CellSelectionCallback', @this.tableSelection, ...
                'CellEditCallback', @this.tableEdit, ...
                'Tag','Derived Forcing Transform', ...
                'TooltipString', toolTip_forcingDerived);
            
            set( this.derivedForcingTranforms.vbox, 'ColumnSizes', -1, 'RowSizes', [35 -1] );            

            % Find java sorting object in table
            jscrollpane = findjobj(this.derivedForcingTranforms.tbl);
            jtable = jscrollpane.getViewport.getView;

            % Turn the JIDE sorting on
            jtable.setSortable(true);
            jtable.setAutoResort(true);
            jtable.setMultiColumnSortable(true);
            jtable.setPreserveSelectionsAfterSorting(true);            
                        
            % Build the weighting function settings items
            this.weightingFunctions.vbox = uiextras.Grid('Parent', this.modelComponants,'Padding', 3, 'Spacing', 3);
            this.weightingFunctions.lbl = uicontrol( 'Parent', this.weightingFunctions.vbox,'Style','text','String','2. Weighting Functions (required)','Visible','on');
            this.weightingFunctions.tbl = uitable('Parent',this.weightingFunctions.vbox,'ColumnName',cnames_weighting,...
                'ColumnEditable',cedit_weighting,'ColumnFormat',cformats_weighting,'RowName',...
                rnames_weighting ,'Data',cdata_weighting, 'Visible','on', 'Units','normalized', ...
                'CellSelectionCallback', @this.tableSelection, ...
                'Tag','Weighting Functions', ...
                'TooltipString', toolTip_weighting);
            
            set( this.weightingFunctions.vbox, 'ColumnSizes', -1, 'RowSizes', [35 -1] );    

            % Find java sorting object in table
            drawnow();
            jscrollpane = findjobj(this.weightingFunctions.tbl);
            jtable = jscrollpane.getViewport.getView;

            % Turn the JIDE sorting on
            jtable.setSortable(true);
            jtable.setAutoResort(true);
            jtable.setMultiColumnSortable(true);
            jtable.setPreserveSelectionsAfterSorting(true);            
                        
            % Build the derived weighting functions
            this.derivedWeightingFunctions.vbox = uiextras.Grid('Parent', this.modelComponants,'Padding', 3, 'Spacing', 3);
            this.derivedWeightingFunctions.lbl = uicontrol( 'Parent', this.derivedWeightingFunctions.vbox,'Style','text','String','4. Derived Weighting Functions (optional)','Visible','on');
            this.derivedWeightingFunctions.tbl = uitable('Parent',this.derivedWeightingFunctions.vbox,'ColumnName',cnames_weightingDerived,...
                'ColumnEditable',cedit_weightingDerived,'ColumnFormat',cformats_weightingDerived,'RowName',...
                rnames_weightingDerived ,'Data',cdata_weightingDerived, 'Visible','on', 'Units','normalized', ...
                'CellSelectionCallback', @this.tableSelection, ...
                'CellEditCallback', @this.tableEdit, ...
                'Tag','Derived Weighting Functions', ...
                'TooltipString', toolTip_weightingDerived);
            
            set( this.derivedWeightingFunctions.vbox, 'ColumnSizes', -1, 'RowSizes', [35 -1] );
            
            % Find java sorting object in table
            jscrollpane = findjobj(this.derivedWeightingFunctions.tbl);
            jtable = jscrollpane.getViewport.getView;

            % Turn the JIDE sorting on
            jtable.setSortable(true);
            jtable.setAutoResort(true);
            jtable.setMultiColumnSortable(true);
            jtable.setPreserveSelectionsAfterSorting(true);            

            % Build the forcing transformation and weighting function options
            %----------------------------------------
            % Create box for the sub-boxes
            this.modelOptions.grid = uiextras.Grid('Parent',this.Figure,'Padding', 3, 'Spacing', 3);
            
            % Add list box for selecting the input forcing data
            cnames = {'Required Model Data', 'Input Forcing Data'};
            cedit = logical([0 1]);
            rnames = {'1'};
            cdata = cell(1,2);
            cformats = {'char', 'char'};
                      
            this.modelOptions.options{1,1}.ParentName = 'forcingTranforms';
            this.modelOptions.options{1,1}.ParentSettingName = 'inputForcing';
            this.modelOptions.options{1,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{1,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{1,1}.box,'Style','text','String','1. Forcing Transform - Input Data','Visible','on');     
            this.modelOptions.options{1,1}.tbl =  uitable('Parent',this.modelOptions.options{1,1}.box,'ColumnName',cnames,...
                                                'ColumnEditable',cedit,'ColumnFormat',cformats,'RowName',...
                                                rnames,'Data',cdata, 'Visible','on', 'Units','normalized', ...
                                                'CellEditCallback', @this.optionsSelection, ...                                                
                                                'Tag','Forcing Transform - Input Data');
            set(this.modelOptions.options{1,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );

            % Add table for defining the transformation options eg soil
            % moisture model parameters for calibration.
            data = [];
            this.modelOptions.options{2,1}.ParentName = 'forcingTranforms';
            this.modelOptions.options{2,1}.ParentSettingName = 'options';            
            this.modelOptions.options{2,1}.box = uiextras.Grid('Parent',  this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{2,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{2,1}.box,'Style','text','String','1. Forcing Transform - Model Settings','Visible','on');     
            this.modelOptions.options{2,1}.tbl = uitable( 'Parent', this.modelOptions.options{2,1}.box,'ColumnName',{'Parameter','(none set)'}, ...
                'ColumnEditable',true,'Data',[], ...
                'CellEditCallback', @this.optionsSelection, ...    
                'Tag','Forcing Transform - Model Settings', 'Visible','on');
            set(this.modelOptions.options{2,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );
                       
            % Add list box for selecting the weighting functions input
            % data.
            % NOTE: Multiple selection of input forcing data is allowed.
            % This is defined in tableSelection().
            this.modelOptions.options{3,1}.ParentName = 'weightingFunctions';
            this.modelOptions.options{3,1}.ParentSettingName = 'inputForcing';                     
            this.modelOptions.options{3,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{3,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{3,1}.box,'Style','text','String','2. Weighting Functions - Input Data','Visible','on');     
            this.modelOptions.options{3,1}.lst = uicontrol('Parent',this.modelOptions.options{3,1}.box,'Style','list', 'BackgroundColor','w', ...
                'String',{},'Value',1,'Tag','Weighting Functions - Input Data','Callback', @this.optionsSelection, 'Visible','on');
            set(this.modelOptions.options{3,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );

            % Add table for selecting the weighting functions options
            this.modelOptions.options{4,1}.ParentName = 'weightingFunctions';
            this.modelOptions.options{4,1}.ParentSettingName = 'options';                     
            this.modelOptions.options{4,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{4,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{4,1}.box,'Style','text','String','2. Weighting Functions - Model Settings','Visible','on');     
            this.modelOptions.options{4,1}.tbl = uitable( 'Parent', this.modelOptions.options{4,1}.box,'ColumnName',{'(none)'}, ...
                'ColumnEditable',true,'Data',[], 'Tag','Weighting Functions - Model Settings', ...
                'CellEditCallback', @this.optionsSelection, 'Visible','on');
            set(this.modelOptions.options{4,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );            
            
            
            % Add table for defining the transformation options eg soil
            % moisture model parameters for calibration.            
            this.modelOptions.options{5,1}.ParentName = 'DerivedForcingTransformation';
            this.modelOptions.options{5,1}.ParentSettingName = 'inputForcing';                     
            this.modelOptions.options{5,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{5,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{5,1}.box,'Style','text','String','3. Derived Forcing Transform - Input Data','Visible','on');     
            this.modelOptions.options{5,1}.lst = uicontrol('Parent',this.modelOptions.options{5,1}.box,'Style','list', 'BackgroundColor','w', ...
                'String',{},'Value',1, ...
                 'Tag','Derived Forcing Functions - Source Function', ...
                'Callback', @this.optionsSelection, 'Visible','on');
            set(this.modelOptions.options{5,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );            

            % Add table for derived forcing inut data options
            this.modelOptions.options{6,1}.ParentName = 'DerivedForcingTransformation';           
            this.modelOptions.options{6,1}.ParentSettingName = 'inputForcing';
            this.modelOptions.options{6,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{6,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{6,1}.box, ...
                'Style','text', ...
                'String','3. Derived Forcing Transform - Input Data','Visible','on');     
            this.modelOptions.options{6,1}.tbl =  uitable('Parent',this.modelOptions.options{6,1}.box,'ColumnName',cnames,...
                'ColumnEditable',cedit,'ColumnFormat',cformats,'RowName',...
                rnames,'Data',cdata, 'Visible','on', 'Units','normalized', ...
                'CellEditCallback', @this.optionsSelection, ...                                                
                'Tag','Derived Forcing Functions - Input Data');
            set(this.modelOptions.options{6,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );
                        
            % Add table for derived forcing options
            this.modelOptions.options{7,1}.ParentName = 'DerivedForcingTransformation';
            this.modelOptions.options{7,1}.ParentSettingName = 'options';            
            this.modelOptions.options{7,1}.box = uiextras.Grid('Parent',  this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{7,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{7,1}.box,'Style','text','String','3. Derived Forcing Transform - Model Settings','Visible','on');     
            this.modelOptions.options{7,1}.tbl = uitable( 'Parent', this.modelOptions.options{7,1}.box,'ColumnName',{'Parameter','(none set)'}, ...
                'ColumnEditable',true,'Data',[], ...
                'CellEditCallback', @this.optionsSelection, ...    
                'Tag','Derived Forcing Transform - Model Settings', 'Visible','on');
            set(this.modelOptions.options{7,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );

            % Add list box for selecting the derived weighting functions input
            % data.
            % NOTE: Multiple selection of input forcing data is allowed.
            % This is defined in tableSelection().
            this.modelOptions.options{8,1}.ParentName = 'derivedWeightingFunctions';
            this.modelOptions.options{8,1}.ParentSettingName = 'inputForcing';                     
            this.modelOptions.options{8,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{8,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{8,1}.box,'Style','text','String','4. Derived Weighting Functions - Input Data','Visible','on');     
            this.modelOptions.options{8,1}.lst = uicontrol('Parent',this.modelOptions.options{8,1}.box,'Style','list', 'BackgroundColor','w', ...
                'String',{},'Value',1,'Tag','Derived Weighting Functions - Input Data','Callback', @this.optionsSelection, 'Visible','on');
            set(this.modelOptions.options{8,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );

            % Add table for selecting the derived weighting functions options
            this.modelOptions.options{9,1}.ParentName = 'derivedWeightingFunctions';
            this.modelOptions.options{9,1}.ParentSettingName = 'options';                     
            this.modelOptions.options{9,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{9,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{9,1}.box,'Style','text','String','4. Derived Weighting Functions - Model Settings','Visible','on');     
            this.modelOptions.options{9,1}.tbl = uitable( 'Parent', this.modelOptions.options{9,1}.box,'ColumnName',{'(none)'}, ...
                'ColumnEditable',true,'Data',[], 'Tag','Derived Weighting Functions - Model Settings', ...
                'CellEditCallback', @this.optionsSelection, 'Visible','on');
            set(this.modelOptions.options{9,1}.box, 'ColumnSizes', -1, 'RowSizes', [35 -1] );                                   
            
            % Add label for general communications to user eg to state that
            % a weighting fnction has no options available.
            this.modelOptions.options{10,1}.ParentName = 'general';
            this.modelOptions.options{10,1}.ParentSettingName = 'general';                     
            this.modelOptions.options{10,1}.box = uiextras.Grid('Parent', this.modelOptions.grid,'Padding', 3, 'Spacing', 3);                        
            this.modelOptions.options{10,1}.lbl = uicontrol( 'Parent', this.modelOptions.options{10,1}.box,'Style','text','String','(empty)','Visible','on');                 
            %----------------------------------------

            % Add context menu for adding /deleting rows
            % NOTE: UIContextMenu.UserData is used to store the table name
            % for the required operation.
            %----------------------------------------
            % Create menu for forcing transforms
            contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent.Parent,'Visible','on');
            uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Separator','on');
            uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
            uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);                
            set(this.forcingTranforms.tbl,'UIContextMenu',contextMenu);
            set(this.forcingTranforms.tbl.UIContextMenu,'UserData', 'this.forcingTranforms.tbl');
            
            % Create menu for weighting functions
            contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent.Parent,'Visible','on');
            uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Separator','on');
            uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
            uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);            
            set(this.weightingFunctions.tbl,'UIContextMenu',contextMenu);
            set(this.weightingFunctions.tbl.UIContextMenu,'UserData', 'this.weightingFunctions.tbl');
            
            % Create menu for derived forcing transforms
            contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent.Parent,'Visible','on');
            uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Separator','on');
            uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
            uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);            
            set(this.derivedForcingTranforms.tbl,'UIContextMenu',contextMenu);
            set(this.derivedForcingTranforms.tbl.UIContextMenu,'UserData', 'this.derivedForcingTranforms.tbl');

            % Create menu for derived weighting functions
            contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent.Parent,'Visible','on');
            uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Separator','on');
            uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
            uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
            uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);            
            set(this.derivedWeightingFunctions.tbl,'UIContextMenu',contextMenu);
            set(this.derivedWeightingFunctions.tbl.UIContextMenu,'UserData', 'this.derivedWeightingFunctions.tbl');
            
            %----------------------------------------            
            % Set dimensions for the grid     
            set( this.modelComponants, 'ColumnSizes', [-3 -1], 'RowSizes', [-1 -1] );      
            this.Figure.Heights = [-3 -1];
            this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Heights));
        end
        
        function initialise(this)
            
        end
        
        function setForcingData(this, fname)

             % Check fname file exists.
             if exist(fname,'file') ~= 2;
                warndlg(['The following forcing data file does not exist:', fname]);
                return;
             end

             % Read in the file.
             try
                tbl = readtable(fname);
             catch
                warndlg(['The following forcing data file could not be read in. It must a .csv file of at least 4 columns (year, month, day, value):',fname]);
                return;
             end

             % Check there are sufficient number of columns
             if length(tbl.Properties.VariableNames) <4
                warndlg(['The following forcing data file must contain at least 4 columns (year, month, day, value):',fname]);
                return;
             end

             % Check all columns are numeric.
             if any(any(~isnumeric(tbl{:,:})))
                warndlg(['All columns within the following forcing data must contain only numeric data:',fname]);
                return;
             end

             % Set the column names.
             this.forcingData.colnames = tbl.Properties.VariableNames;
             
             % Clear tbl
             clear tbl;
            
        end
        
        function setCoordinatesData(this, fname)
             % Check fname file exists.
             if exist(fname,'file') ~= 2;
                warndlg(['The following site coordinates file does not exist:', fname]);
                return;
             end

             % Read in the file.
             try
                tbl = readtable(fname);
             catch
                warndlg(['The following site coordinates file could not be read in. It must a .csv file of 3 columns (site ID, easting, northing):',fname]);
                return;
             end

             % Check there are sufficient number of columns
             if length(tbl.Properties.VariableNames) ~=3
                warndlg(['The following site coordinates file must contain 3 columns  (site ID, easting, northing):',fname]);
                return;
             end

             % Check all columns are numeric.
             if any(any(~isnumeric(tbl{:,2:3})))
                warndlg(['Columns 2 and 3 within the following site coordinates file must contain only numeric data:',fname]);
                return;
             end

             % Set the site data.
             this.siteData = tbl;
             
             % Clear tbl
             clear tbl;
            
        end
        
        function setBoreID(this, boreID)
            this.boreID = boreID;
        end
        
        function setModelOptions(this, modelOptionsStr)
            
        end
        
        function modelOptionsArray = getModelOptions(this)
            % Convert forcing tranformation functions to strings.
            cellData  = this.forcingTranforms.tbl.Data;
            for i=1:size(cellData ,1);
               stringCell = '{';           
               stringCell = strcat(stringCell, sprintf(' ''transformfunction'',  ''%s'';',cellData{i,2} ));
               stringCell = strcat(stringCell, sprintf(' ''forcingdata'', ''%s'';',cellData{i,3} )); 
               if ~isempty(cellData{i,4})
                    stringCell = strcat(stringCell, sprintf(' ''options'', ''%s'';',cellData{i,4} )); 
               end
               stringCell = strcat(stringCell, '}'); 
               forcingString.(cellData{i,2}) = stringCell;
               
               % Initialise logical variable denoting if its already been
               % inserted.
               forcingStringInserted.(cellData{i,2}) = false;
            end
            
            % Convert weighting functions to string.
            modelOptionsArray =  '{';
            cellData  = this.weightingFunctions.tbl.Data;
            for i=1:size(cellData ,1);                 
               modelOptionsArray = strcat(modelOptionsArray, sprintf(' ''%s'', ''weightingfunction'',  ''%s'';',cellData{i,2},cellData{i,3} ));
               
               % Convert forcing data to a cell array
               try
                   forcingColNames =  eval(cellData{i,4});
               catch
                   forcingColNames =  cellData(i,4);
               end
                              
               % Loop through each forcing data input.
               for j=1:length(forcingColNames)

                   % Insert input data.                     
                   if ~isempty(strfind(forcingColNames{j}, 'Input Data : '))
                       [ind_start, ind_end] = regexp(forcingColNames{j}, 'Input Data : ');
                       forcingColNames_tmp =  forcingColNames{j}(ind_end+1:end);
                       ind_start = regexp(forcingColNames_tmp, '''');
                       if ~isempty(ind_start)
                            forcingColNames_tmp =  forcingColNames_tmp(1:ind_start-1);
                       end
                   else
                       % Find function name
                       forcingFunc_Ind = regexp(forcingColNames{j}, ' : ');  
                       forcingFuncName = forcingColNames{j}(1:forcingFunc_Ind-1);

                       % Insert cell array string for required function name.
                       % If the forcing function has already been inserted then
                       % just build a string for the forcing to be extracted
                       % from it.
                       if ~forcingStringInserted.(forcingFuncName) 
                            % Get just output name from string
                           [ind_start, ind_end] = regexp(forcingColNames{j}, [forcingFuncName,' : ']);
                           forcingColNames_tmp =  forcingColNames{j}(ind_end+1:end);
                            
                            % Add required output from weighting function to forcing function cell array
                            forcingString.(forcingFuncName) = forcingString.(forcingFuncName)(1:end-1);
                            forcingString.(forcingFuncName) = strcat(forcingString.(forcingFuncName), ...
                                 sprintf(' ''outputdata'' , ''%s'' };', forcingColNames_tmp ) );
                            forcingColNames_tmp = forcingString.(forcingFuncName);
                            forcingStringInserted.(forcingFuncName) = true;
                       else
                           
                           % Create cell array for an already created
                           % forcing transform function but only declare
                           % the forcing to be taken from the function.
                           forcingColNames_tmp = { 'transformfunction', forcingFuncName; 'outputdata', forcingColNames{j}};
                           
                           % Convert to a string
                           className = metaclass(this);
                           colnames = {'component','property','value'};
                           forcingColNames_tmp =  eval([className,'.cell2string(forcingColNames_tmp, colnames)']);                           
                       end

                   end
                   
                   % Add forcing string to the model options string
                   if length(forcingColNames)==1
                        modelOptionsArray = strcat(modelOptionsArray, sprintf(' ''%s'', ''forcingdata'', ''%s'';',cellData{i,2}, forcingColNames_tmp ));                            
                   elseif length(forcingColNames)>1 && j==1
                        modelOptionsArray = strcat(modelOptionsArray, sprintf(' ''%s'', ''forcingdata'', { ''%s'';',cellData{i,2}, forcingColNames_tmp ));                            
                   elseif length(forcingColNames)>1 && j==length(forcingColNames)
                        modelOptionsArray = strcat(modelOptionsArray, sprintf(' ''%s'' };',forcingColNames_tmp ));                                                    
                   else                           
                        modelOptionsArray = strcat(modelOptionsArray, sprintf(' ''%s'';',forcingColNames_tmp ));
                   end                       
               end

               
               % Add model options 
               if ~isempty(cellData{i,5})
                    modelOptionsArray = strcat(modelOptionsArray, sprintf(' ''%s'', ''options'', ''%s'';',cellData{i,2},cellData{i,5} )); 
               end
                              
            end
            modelOptionsArray= strcat(modelOptionsArray, '}'); 

            % Remove any ' symbols for cell arrays internal to the larger
            % string.
            while ~isempty(strfind(modelOptionsArray, '}''' ))
                ind = strfind(modelOptionsArray, '}''' );
                ind = ind(1);
                modelOptionsArray = [modelOptionsArray(1:ind),  modelOptionsArray(ind+2:end)];
            end
            while ~isempty(strfind(modelOptionsArray, '''{' ))
                ind = strfind(modelOptionsArray, '''{' );
                ind = ind(1);
                modelOptionsArray = [modelOptionsArray(1:ind-1),  modelOptionsArray(ind+1:end)];
            end            
            while ~isempty(strfind(modelOptionsArray, ';'';' ))
                ind = strfind(modelOptionsArray, ';'';' );
                ind = ind(1);
                modelOptionsArray = [modelOptionsArray(1:ind),  modelOptionsArray(ind+3:end)];
            end             
        end
        
        
        function tableSelection(this, hObject, eventdata)
            icol=[];
            irow=[];
            if isprop(eventdata, 'Indices')
                if ~isempty(eventdata.Indices)
                    icol=eventdata.Indices(:,2);
                    irow=eventdata.Indices(:,1);  
                end
            end
            
            if size(get(hObject,'Data'),1)==0
                return
            end
            
            % Get the data cell array of the table
            data=get(hObject,'Data'); 
            
            % Undertake table/list specific operations.
            switch eventdata.Source.Tag;
                case 'Forcing Transform'
                    % Record the current table, row, col if the inputs are
                    % not empty. Else, extract the exiting values from
                    % this.currentSelection                    
                    if ~isempty(irow) && ~isempty(icol)
                        this.currentSelection.row = irow;
                        this.currentSelection.col= icol;
                        this.currentSelection.table = eventdata.Source.Tag;
                    else
                        irow = this.currentSelection.row;
                        icol = this.currentSelection.col;                                                
                    end

                    % Get the forcing function name.
                    funName = data{irow, 2};

                    switch eventdata.Source.ColumnName{icol};
                        case 'Forcing Transform Function'
                            % Do nothing.

                        case 'Input Data'
                           % Call function method giving required
                           % variable name.
                           requiredVariables = feval(strcat(funName,'.inputForcingData_required'));

                           % Add row for each required variable
                           if isempty(this.forcingTranforms.tbl.Data{this.currentSelection.row ,3})
                               for i=1:length(requiredVariables)                                   
                                    this.modelOptions.options{1, 1}.tbl.Data{i,1}= requiredVariables{i};
                                    this.modelOptions.options{1, 1}.tbl.RowName{i}= num2str(i);
                               end
                           else
                               try
                                   this.modelOptions.options{1, 1}.tbl.Data = eval(this.forcingTranforms.tbl.Data{irow,3});
                                   for i=1:length(requiredVariables)                                                                           
                                        this.modelOptions.options{1, 1}.tbl.RowName{i}= num2str(i);
                                   end
                               catch
                                   warning('The input string appears to have a syntax error. It should be an Nx2 cell array.');                                       
                               end
                           end

                           % Define the drop down options for the input
                           % data
                           this.modelOptions.options{1, 1}.tbl.ColumnFormat = {'char',this.forcingData.colnames(4:end)};

                           % Display table
                           this.modelOptions.grid.Widths = [-1 0 0 0 0 0 0 0 0 0];

                        case 'Options' 

                           % Get the model options.
                           [modelSettings, colNames, colFormats, colEdits, tooltips] = feval(strcat(funName,'.modelOptions'));

                           % Check if options are available.
                           if isempty(colNames)                          
                                this.modelOptions.options{2,1}.lbl.String = {'1. Forcing Transform - Model Settings',['(No options are available for the following weighting function: ',funName,')']};
                                this.modelOptions.grid.Widths = [0 -1 0 0 0 0 0 0 0 0];
                           else

                               % Assign model properties and data
                               this.modelOptions.options{2,1}.tbl.ColumnName = colNames;
                               this.modelOptions.options{2,1}.tbl.ColumnEditable = colEdits;
                               this.modelOptions.options{2,1}.tbl.ColumnFormat = colFormats;                               
                               this.modelOptions.options{2,1}.tbl.TooltipString = tooltips;                               
                               this.modelOptions.options{2,1}.tbl.Tag = 'Forcing Transform - Model Settings';                                                              

                               if isempty(this.forcingTranforms.tbl.Data{this.currentSelection.row ,4})
                                    this.modelOptions.options{2,1}.tbl.Data = modelSettings;
                               else
                                   try                                       
                                       data = eval(this.forcingTranforms.tbl.Data{irow,4});
                                       if strcmpi(colNames(1),'Select')
                                           data = [ mat2cell(false(size(data,1),1),ones(1,size(data,1))),  data];
                                       end

                                       this.modelOptions.options{2, 1}.tbl.Data = data;
                                   catch
                                       warning('The function options string appears to have a sytax error. It should be an Nx4 cell array.');                                       
                                   end
                               end

                               % Assign context menu if the first column is
                               % named 'Select' and is a tick box.
                               if strcmp(colNames{1},'Select') && strcmp(colFormats{1},'logical')
                                    contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent,'Visible','on');
                                    uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Separator','on');
                                    uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
                                    uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);            
                                    set(this.modelOptions.options{2, 1}.tbl,'UIContextMenu',contextMenu);  
                                    set(this.modelOptions.options{2, 1}.tbl.UIContextMenu,'UserData', 'this.modelOptions.options{2, 1}.tbl');
                               else
                                   set(this.modelOptions.options{2, 1}.tbl,'UIContextMenu',[]);
                               end                               
                               
                               % Show table
                               this.modelOptions.grid.Widths = [0 -1 0 0 0 0 0 0 0 0];  
                           end
                        otherwise
                            this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));
                    end
                case 'Weighting Functions'

                    % Record the current table, row, col if the inputs are
                    % not empty. Else, extract the exiting values from
                    % this.currentSelection                    
                    if ~isempty(irow) && ~isempty(icol)
                        this.currentSelection.row = irow;
                        this.currentSelection.col= icol;
                        this.currentSelection.table = eventdata.Source.Tag;
                    else
                        irow = this.currentSelection.row;
                        icol = this.currentSelection.col;                                                
                    end

                    switch eventdata.Source.ColumnName{icol};
                        case 'Input Data'
                           % Get the list of input forcing data.
                           lstOptions = reshape(this.forcingData.colnames(4:end),[length(this.forcingData.colnames(4:end)),1]);

                           % Add source name
                           lstOptions = strcat('Input Data :',{' '}, lstOptions);

                           % Loop through each forcing function and add
                           % the possible outputs.
                           for i=1: size(this.forcingTranforms.tbl.Data,1)
                               if isempty(this.forcingTranforms.tbl.Data{i,2})
                                   continue
                               end

                               % Get output options.
                               outputOptions = feval(strcat(this.forcingTranforms.tbl.Data{i,2},'.outputForcingdata_options'));

                               % Add output options from the function
                               % to the list of available options
                               lstOptions = [lstOptions; strcat(this.forcingTranforms.tbl.Data{i,2},{' : '}, outputOptions)];
                           end


                           % Loop through each derived forcing function and add
                           % the possible outputs.
                           for i=1: size(this.derivedForcingTranforms.tbl.Data,1)
                               if isempty(this.derivedForcingTranforms.tbl.Data{i,2})
                                   continue
                               end

                               % Get output options.
                               outputOptions = feval(strcat(this.derivedForcingTranforms.tbl.Data{i,2},'.outputForcingdata_options'));

                               % Add output options from the function
                               % to the list of available options
                               lstOptions = [lstOptions; strcat(this.derivedForcingTranforms.tbl.Data{i,2},{' : '}, outputOptions)];
                           end                                                      
                           
                           % Assign the list of options to the list box                               
                           this.modelOptions.options{3,1}.lst.String = lstOptions;
                           
                           % Allow multipple-selection.
                           this.modelOptions.options{3,1}.lst.Min = 1;
                           this.modelOptions.options{3,1}.lst.Max = length(lstOptions);
                           
                           % Show the list box
                           this.modelOptions.grid.Widths = [0 0 -1 0 0 0 0 0 0 0];

                        case 'Options'
                            % Check that the weigthing function and forcing
                            % data have been defined
                            if any(isempty(this.weightingFunctions.tbl.Data(this.currentSelection.row,2:4)))
                                warning('The component name, weighting function ands input data must be specified before setting the options.');
                                return;
                            end
                            
                            % Get the input forcing data options.
                            inputDataNames = this.weightingFunctions.tbl.Data{this.currentSelection.row, 4};
                            
                            % Convert input data to a cell array if it is a
                            % list of multiple inputs.
                            inputDataNames = eval(inputDataNames)';
                            
                            % Get the list of input forcing data.
                            funName = this.weightingFunctions.tbl.Data{this.currentSelection.row, 3};

                           % Get the weighting function options.
                           [modelSettings, colNames, colFormats, colEdits] = feval(strcat(funName,'.modelOptions'), ...
                           this.boreID, inputDataNames, this.siteData);

                           % If the function has any options the
                           % display the options else display a message
                           % in box stating no options are available.
                           if isempty(colNames)                          
                                this.modelOptions.options{10,1}.lbl.String = {'2. Weighting Functions - Options',['(No options are available for the following weighting function: ',funName,')']};                                    
                                this.modelOptions.grid.Widths = [0 0 0 0 0 0 0 0 0 -1];
                           else
                               this.modelOptions.options{4,1}.lbl.String = '2. Weighting Functions - Options';

                               % Assign model properties and data
                               this.modelOptions.options{4,1}.tbl.ColumnName = colNames;
                               this.modelOptions.options{4,1}.tbl.ColumnEditable = colEdits;
                               this.modelOptions.options{4,1}.tbl.ColumnFormat = colFormats;                               
                               
                               % Input the existing data or else the
                               % default settings.
                               if isempty(this.weightingFunctions.tbl.Data{this.currentSelection.row ,5})
                                   if isempty(modelSettings)
                                       this.modelOptions.options{4,1}.tbl.Data = cell(1,length(colNames));
                                   else
                                       this.modelOptions.options{4,1}.tbl.Data = modelSettings;
                                   end
                               else
                                   try
                                       data = eval(this.weightingFunctions.tbl.Data{this.currentSelection.row ,5});
                                       if strcmpi(colNames(1),'Select')
                                           data = [ mat2cell(false(size(data,1),1),ones(1,size(data,1))) , data];
                                       end

                                       this.modelOptions.options{4, 1}.tbl.Data = data;
                                   catch
                                       warning('The function options string appears to have a sytax error. It should be an Nx4 cell array.');                                       
                                   end
                               end                                 
                               % Assign context menu if the first column is
                               % named 'Select' and is a tick box.
                               if strcmp(colNames{1},'Select') && strcmp(colFormats{1},'logical')
                                    contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent,'Visible','on');
                                    uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Separator','on');
                                    uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
                                    uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);            
                                    set(this.modelOptions.options{4, 1}.tbl,'UIContextMenu',contextMenu);  
                                    set(this.modelOptions.options{4, 1}.tbl.UIContextMenu,'UserData', 'this.modelOptions.options{4, 1}.tbl');
                               else
                                   set(this.modelOptions.options{4, 1}.tbl,'UIContextMenu',[]);
                               end
                               
                               % Show table
                               this.modelOptions.grid.Widths = [0 0 0 -1 0 0 0 0 0 0];
                           end

                        otherwise
                            this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));
                    end

                case 'Derived Forcing Transform'

                    % Record the current table, row, col if the inputs are
                    % not empty. Else, extract the exiting values from
                    % this.currentSelection                    
                    if ~isempty(irow) && ~isempty(icol)
                        this.currentSelection.row = irow;
                        this.currentSelection.col= icol;
                        this.currentSelection.table = eventdata.Source.Tag;
                    else
                        irow = this.currentSelection.row;
                        icol = this.currentSelection.col;                                                
                    end                      
                    
                    % Get the derived forcing function name.
                    funName = data{irow, 2};

                    % Get the source forcing function name.
                    sourceFunName = data{irow, 3};

                    switch eventdata.Source.ColumnName{icol};
                        case 'Source Forcing Function' 
                            derivedForcingFunctionsListed = this.forcingTranforms.tbl.Data(:,2);
                            this.derivedForcingTranforms.tbl.ColumnFormat{3} = derivedForcingFunctionsListed;
                            this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));
                        case 'Input Data'
                           % Call function method giving required
                           % variable name.
                           requiredVariables = feval(strcat(funName,'.inputForcingData_required'));

                           % Add row for each required variable
                           if isempty(this.derivedForcingTranforms.tbl.Data{this.currentSelection.row ,4})
                               for i=1:length(requiredVariables)                                   
                                    this.modelOptions.options{6, 1}.tbl.Data{i,1}= requiredVariables{i};
                                    this.modelOptions.options{6, 1}.tbl.RowName{i}= num2str(i);
                               end
                           else
                               try
                                   this.modelOptions.options{6, 1}.tbl.Data = eval(this.derivedForcingTranforms.tbl.Data{irow,4});
                                   for i=1:length(requiredVariables)                                                                           
                                        this.modelOptions.options{6, 1}.tbl.RowName{i}= num2str(i);
                                   end
                               catch
                                   warning('The input string appears to have a syntax error. It should be an Nx2 cell array.');                                       
                               end
                           end
                           
                           % Get the list of input forcing data and add source name
                           lstOptions = reshape(this.forcingData.colnames(4:end),[1, length(this.forcingData.colnames(4:end))]);
                           lstOptions = strcat('Input Data :',{' '}, lstOptions);

                           % Add input list to drop down
                           this.modelOptions.options{6, 1}.tbl.ColumnFormat = {'char',lstOptions};

                           % Display table
                           this.modelOptions.grid.Widths = [0 0 0 0 0 -1 0 0 0 0];
                           
                        case 'Options'    
                           % Get the model options.
                           [modelSettings, colNames, colFormats, colEdits, tooltips] = feval(strcat(funName,'.modelOptions'), sourceFunName );

                           % Check if options are available.
                           if isempty(colNames)                          
                                this.modelOptions.options{10,1}.lbl.String = {'3. Derived Forcing Transform - Model Settings',['(No options are available for the following function: ',funName,')']};
                                this.modelOptions.grid.Widths = [0 0 0 0 0 0 0 0 0 -1];
                           else

                               % Assign model properties and data
                               this.modelOptions.options{7,1}.tbl.ColumnName = colNames;
                               this.modelOptions.options{7,1}.tbl.ColumnEditable = colEdits;
                               this.modelOptions.options{7,1}.tbl.ColumnFormat = colFormats;                               
                               this.modelOptions.options{7,1}.tbl.TooltipString = tooltips;                               
                               this.modelOptions.options{7,1}.tbl.Tag = 'Derived Forcing Transform - Model Settings';                                                              

                               if isempty(this.derivedForcingTranforms.tbl.Data{irow ,5})
                                    this.modelOptions.options{7,1}.tbl.Data = modelSettings;
                               else
                                   try                                       
                                       data = eval(this.derivedForcingTranforms.tbl.Data{irow,5});
                                       if strcmpi(colNames(1),'Select')
                                           data = [ mat2cell(false(size(data,1),1),ones(1,size(data,1))),  data];
                                       end

                                       this.modelOptions.options{7, 1}.tbl.Data = data;
                                   catch
                                       warning('The function options string appears to have a sytax error. It should be an Nx4 cell array.');                                       
                                   end
                               end

                               % Assign context menu if the first column is
                               % named 'Select' and is a tick box.
                               if strcmp(colNames{1},'Select') && strcmp(colFormats{1},'logical')
                                    contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent,'Visible','on');
                                    uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Separator','on');
                                    uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
                                    uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);            
                                    set(this.modelOptions.options{7, 1}.tbl,'UIContextMenu',contextMenu);  
                                    set(this.modelOptions.options{7, 1}.tbl.UIContextMenu,'UserData', 'this.modelOptions.options{2, 1}.tbl');
                               else
                                   set(this.modelOptions.options{7, 1}.tbl,'UIContextMenu',[]);
                               end                               

                               % Display table
                               this.modelOptions.grid.Widths = [0 0 0 0 0 0 -1 0 0 0];                
                           end
                        otherwise
                            this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));
                    end

                case 'Derived Weighting Functions'

                    % Record the current table, row, col if the inputs are
                    % not empty. Else, extract the exiting values from
                    % this.currentSelection                    
                    if ~isempty(irow) && ~isempty(icol)
                        this.currentSelection.row = irow;
                        this.currentSelection.col= icol;
                        this.currentSelection.table = eventdata.Source.Tag;
                    else
                        irow = this.currentSelection.row;
                        icol = this.currentSelection.col;                                                
                    end

                    switch eventdata.Source.ColumnName{icol};
                        case 'Source Component'
                            derivedWeightingFunctionsListed = this.weightingFunctions.tbl.Data(:,2);
                            this.derivedWeightingFunctions.tbl.ColumnFormat{4} = derivedWeightingFunctionsListed;
                            this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));
                        case 'Input Data'
                            
                           % Get the list of input forcing data.
                           lstOptions = reshape(this.forcingData.colnames(4:end),[length(this.forcingData.colnames(4:end)),1]);

                           % Add source name
                           lstOptions = strcat('Input Data :',{' '}, lstOptions);

                           % Loop through each forcing function and add
                           % the possible outputs.
                           for i=1: size(this.forcingTranforms.tbl.Data,1)
                               if isempty(this.forcingTranforms.tbl.Data{i,2})
                                   continue
                               end

                               % Get output options.
                               outputOptions = feval(strcat(this.forcingTranforms.tbl.Data{i,2},'.outputForcingdata_options'));

                               % Add output options from the function
                               % to the list of available options
                               lstOptions = [lstOptions; strcat(this.forcingTranforms.tbl.Data{i,2},{' : '}, outputOptions)];
                           end


                           % Loop through each derived forcing function and add
                           % the possible outputs.
                           for i=1: size(this.derivedForcingTranforms.tbl.Data,1)
                               if isempty(this.derivedForcingTranforms.tbl.Data{i,2})
                                   continue
                               end

                               % Get output options.
                               outputOptions = feval(strcat(this.derivedForcingTranforms.tbl.Data{i,2},'.outputForcingdata_options'));

                               % Add output options from the function
                               % to the list of available options
                               lstOptions = [lstOptions; strcat(this.derivedForcingTranforms.tbl.Data{i,2},{' : '}, outputOptions)];
                           end                                                      
                           
                           % Assign the list of options to the list box                               
                           this.modelOptions.options{8,1}.lst.String = lstOptions;
                           
                           % Allow multipple-selection.
                           this.modelOptions.options{8,1}.lst.Min = 1;
                           this.modelOptions.options{8,1}.lst.Max = length(lstOptions);
                            
                           % Show list box 
                           this.modelOptions.grid.Widths = [0 0 0 0 0 0 0 -1 0 0];
                           
                        case 'Options'
                            % Check that the weigthing function and forcing
                            % data have been defined
                            if any(isempty(this.derivedWeightingFunctions.tbl.Data(this.currentSelection.row,2:5)))
                                warning('The component name, derived weighting function, source function and input data must be specified before setting the options.');
                                return;
                            end
                            
                            % Get the input forcing data options.
                            inputDataNames = this.derivedWeightingFunctions.tbl.Data{this.currentSelection.row, 5};
                            
                            % Convert input data to a cell array if it is a
                            % list of multiple inputs.
                            inputDataNames = eval(inputDataNames)';
                            
                            % Get the list of input forcing data.
                            funName = this.derivedWeightingFunctions.tbl.Data{this.currentSelection.row, 3};

                           % Get the weighting function options.
                           [modelSettings, colNames, colFormats, colEdits] = feval(strcat(funName,'.modelOptions'), ...
                           this.boreID, inputDataNames, this.siteData);

                           % If the function has any options the
                           % display the options else display a message
                           % in box stating no options are available.
                           if isempty(colNames)                          
                                this.modelOptions.options{10,1}.lbl.String = {'4. Derived Weighting Functions - Options',['(No options are available for the following weighting function: ',funName,')']};                                    
                                this.modelOptions.grid.Widths = [0 0 0 0 0 0 0 0 0 -1];
                           else
                               this.modelOptions.options{9,1}.lbl.String = '4. Derived Weighting Functions - Options';

                               % Assign model properties and data
                               this.modelOptions.options{9,1}.tbl.ColumnName = colNames;
                               this.modelOptions.options{9,1}.tbl.ColumnEditable = colEdits;
                               this.modelOptions.options{9,1}.tbl.ColumnFormat = colFormats;                               
                               
                               % Input the existing data or else the
                               % default settings.
                               if isempty(this.derivedWeightingFunctions.tbl.Data{this.currentSelection.row ,6})
                                   if isempty(modelSettings)
                                       this.modelOptions.options{9,1}.tbl.Data = cell(1,length(colNames));
                                   else
                                       this.modelOptions.options{9,1}.tbl.Data = modelSettings;
                                   end
                               else
                                   try
                                       data = eval(this.derivedWeightingFunctions.tbl.Data{this.currentSelection.row ,6});
                                       if strcmpi(colNames(1),'Select')
                                           data = [ mat2cell(false(size(data,1),1),ones(1,size(data,1))) , data];
                                       end

                                       this.modelOptions.options{9, 1}.tbl.Data = data;
                                   catch
                                       warning('The function options string appears to have a sytax error.');                                       
                                   end
                               end                                 
                               % Assign context menu if the first column is
                               % named 'Select' and is a tick box.
                               if strcmp(colNames{1},'Select') && strcmp(colFormats{1},'logical')
                                    contextMenu = uicontextmenu(this.Figure.Parent.Parent.Parent.Parent.Parent,'Visible','on');
                                    uimenu(contextMenu,'Label','Copy selected rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Paste rows','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Separator','on');
                                    uimenu(contextMenu,'Label','Insert row above selection','Callback',@this.rowAddDelete);
                                    uimenu(contextMenu,'Label','Insert row below selection','Callback',@this.rowAddDelete);            
                                    uimenu(contextMenu,'Label','Delete selected rows','Callback',@this.rowAddDelete);            
                                    set(this.modelOptions.options{9, 1}.tbl,'UIContextMenu',contextMenu);  
                                    set(this.modelOptions.options{9, 1}.tbl.UIContextMenu,'UserData', 'this.modelOptions.options{9, 1}.tbl');
                               else
                                   set(this.modelOptions.options{9, 1}.tbl,'UIContextMenu',[]);
                               end
                               
                               % Show table
                               this.modelOptions.grid.Widths = [0 0 0 -1 0 0 0 0 0 0];
                           end
                        otherwise
                            this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));
                    end   
            end            
        end
        
        function optionsSelection(this, hObject, eventdata)
            try
                data=get(hObject,'Data'); % get the data cell array of the table
            catch
                data=[];
            end

            % Get class name (for calling the abstract)
            className = metaclass(this);
            className = className.Name;
                        
            % Undertake table/list specific operations.
            switch eventdata.Source.Tag;
               
                case 'Forcing Transform - Input Data'                        
                    colnames = hObject.ColumnName;
                    this.forcingTranforms.tbl.Data{this.currentSelection.row ,3} = eval([className,'.cell2string(data, colnames)']);

                case 'Forcing Transform - Model Settings'
                    colnames = hObject.ColumnName;
                    this.forcingTranforms.tbl.Data{this.currentSelection.row ,4} = eval([className,'.cell2string(data, colnames)']);

                case 'Weighting Functions - Input Data'       

                    % Get selected input option
                    listSelection = get(hObject,'Value');
 
                    % Get cell array of selected strings.
                    data = hObject.String(listSelection);
                    
                    % Convert to string.
                    colnames = 'NA';                    
                    this.weightingFunctions.tbl.Data{this.currentSelection.row ,4} = eval([className,'.cell2string(data, colnames)']);

                case 'Weighting Functions - Model Settings'       
                    colnames = hObject.ColumnName;
                    this.weightingFunctions.tbl.Data{this.currentSelection.row ,5} = eval([className,'.cell2string(data, colnames)']);

                case 'Derived Forcing Functions - Source Function'                      
                    % Get selected input option
                    listSelection = get(hObject,'Value');
 
                    % Get cell array of selected strings.
                    data = hObject.String(listSelection);

                    % Assign to the table
                    this.derivedForcingTranforms.tbl.Data{this.currentSelection.row ,3} = data{1};
                    
                    
                case 'Derived Forcing Functions - Input Data'                      
                    
                    colnames = hObject.ColumnName;
                    this.derivedForcingTranforms.tbl.Data{this.currentSelection.row ,4} = eval([className,'.cell2string(data, colnames)']);
                    
                case 'Derived Forcing Transform - Model Settings'
                    
                    colnames = hObject.ColumnName;
                    this.derivedForcingTranforms.tbl.Data{this.currentSelection.row ,5} = eval([className,'.cell2string(data, colnames)']);
                    
                    
                case 'Derived Weighting Functions - Input Data'      
                    % Get selected input option
                    listSelection = get(hObject,'Value');
 
                    % Get cell array of selected strings.
                    data = hObject.String(listSelection);
                    
                    % Convert to string.
                    colnames = 'NA';                    
                    this.derivedWeightingFunctions.tbl.Data{this.currentSelection.row ,5} = eval([className,'.cell2string(data, colnames)']);

                case 'Derived Weighting Functions - Model Settings'       
                    colnames = hObject.ColumnName;
                    this.derivedWeightingFunctions.tbl.Data{this.currentSelection.row ,6} = eval([className,'.cell2string(data, colnames)']);
                    
                otherwise
                        this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths)); 
            end
        end
        
    end
    
    methods(Access=private)  
        
        function tableEdit(this, hObject, eventdata)
            icol=[];
            irow=[];
            if isprop(eventdata, 'Indices')
                if ~isempty(eventdata.Indices)
                    icol=eventdata.Indices(:,2);
                    irow=eventdata.Indices(:,1);  
                end
            end
            if size(get(hObject,'Data'),1)==0
                return
            end
           
            % Undertake table/list specific operations.
            switch eventdata.Source.Tag;
                case 'Forcing Transform'
                   % Reset other fields of the model name changes
                   if icol==2 && ~isempty(eventdata.PreviousData) && ~strcmp(eventdata.PreviousData, eventdata.NewData)
                        this.forcingTranforms.tbl.Data{irow ,3} = '';
                        this.forcingTranforms.tbl.Data{irow,4} = '';
                        this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));
                        
                   end
                case 'Weighting Functions'
                   % Reset other fields of the model name changes
                   if icol==3 && ~isempty(eventdata.PreviousData) && ~strcmp(eventdata.PreviousData, eventdata.NewData)
                        this.weightingFunctions.tbl.Data{irow ,4} = '';
                        this.weightingFunctions.tbl.Data{irow ,5} = '';
                        this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));                        
                   end                   
                case 'Derived Forcing Transform'
                   % Reset other fields of the model name changes
                   if icol==2 && ~isempty(eventdata.PreviousData) && ~strcmp(eventdata.PreviousData, eventdata.NewData)
                        this.derivedForcingTranforms.tbl.Data{irow ,3} = '';
                        this.derivedForcingTranforms.tbl.Data{irow ,4} = '';
                        this.derivedForcingTranforms.tbl.Data{irow ,5} = '';
                        this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));                        
                   end                   
                case 'Derived Weighting Functions'
                   % Reset other fields of the model name changes
                   if icol==3 && ~isempty(eventdata.PreviousData) && ~strcmp(eventdata.PreviousData, eventdata.NewData)
                        this.derivedWeightingFunctions.tbl.Data{irow ,4} = '';
                        this.derivedWeightingFunctions.tbl.Data{irow ,5} = '';
                        this.derivedWeightingFunctions.tbl.Data{irow ,6} = '';
                        this.modelOptions.grid.Widths = zeros(size(this.modelOptions.grid.Widths));                        
                   end                      
                    
            end
        end
        
        function rowAddDelete(this, hObject, eventdata)

           
            % Get the table object from UserData
            tableObj = eval(eventdata.Source.Parent.UserData);
            
            % Get selected rows
            selectedRow = cell2mat(tableObj.Data(:,1));
            
            if size(tableObj.Data(:,1),1)>0 &&  sum(selectedRow) == 0                             
                warning('No rows are selected for the requested operation.');
                return;
            elseif size(tableObj.Data(:,1),1)==0 ...
            &&  (strcmp(hObject.Label, 'Copy selected rows') || strcmp(hObject.Label, 'Delete selected rows'))                
                return;
            end            
            
            % Do the selected action            
            switch hObject.Label
                case 'Copy selected rows'
                    this.copiedData.tableName = tableObj.Tag;
                    this.copiedData.data = tableObj.Data(selectedRow,:);
                    
                case 'Paste rows'    
                    % Check that name of the table is same as that from the
                    % copied data. If so copy the data.
                    if strcmp(this.copiedData.tableName, tableObj.Tag)
                       tableObj.Data = [tableObj.Data; this.copiedData.data];
                    else
                        warning('The copied row data was sourced froma different table.');
                        return;
                    end    
                    
                    % Update row numbers.
                    nrows = size(tableObj.Data,1);
                    tableObj.RowName = mat2cell([1:nrows]',ones(1, nrows));
                    
                case 'Insert row above selection'
                    if size(tableObj.Data,1)==0
                        tableObj.Data = cell(1,size(tableObj.Data,2));
                    else
                        selectedRow= find(selectedRow);
                        for i=1:length(selectedRow)

                            ind = max(0,selectedRow(i) + i-1);

                            tableObj.Data = [tableObj.Data(1:ind-1,:); ...
                                        cell(1,size(tableObj.Data,2)); ...
                                        tableObj.Data(ind:end,:)];
                            tableObj.Data{ind,1} = false;                                                              
                        end
                    end
                    % Update row numbers.
                    nrows = size(tableObj,1);
                    tableObj.RowName = mat2cell([1:nrows]',ones(1, nrows));
                        
                case 'Insert row below selection'    
                    if size(tableObj.Data,1)==0
                        tableObj.Data = cell(1,size(tableObj.Data,2));
                    else
                        selectedRow= find(selectedRow);
                        for i=1:length(selectedRow)

                            ind = selectedRow(i) + i;

                            tableObj.Data = [tableObj.Data(1:ind-1,:); ...
                                        cell(1,size(tableObj.Data,2)); ...
                                        tableObj.Data(ind:end,:)];

                            tableObj.Data{ind,1} = false;                                                              
                        end
                    end
                    % Update row numbers.
                    nrows = size(tableObj,1);
                    tableObj.RowName = mat2cell([1:nrows]',ones(1, nrows));

                case 'Delete selected rows'    
                    tableObj.Data = tableObj.Data(~selectedRow,:);
                    
                    % Update row numbers.
                    nrows = size(tableObj.Data,1);
                    tableObj.RowName = mat2cell([1:nrows]',ones(1, nrows));
            end
        end
    end
    
    methods(Static, Access=private)  
        function stringCell = cell2string(cellData, colnames) 
                % Ignore first column of it is for row selection
                if strcmpi(colnames(1),'Select')
                    startCol = 2;                    
                else
                    startCol = 1;
                end
            
                % Check the format of each column.
                % All rows of a column must be numeric to be
                % deemed numeric.
                isNumericColumn = all(cellfun(@(x) isnumeric(x) || (~isempty(str2double(x)) && ~isnan(str2double(x))), cellData),1);
                
                % Loop through each column, then row.
                stringCell= '{';
                for i=1:size(cellData,1)
                    for j=startCol:size(cellData,2)
                        
                        if isNumericColumn(j)
                            if ischar(cellData{i,j})
                                stringCell = strcat(stringCell, sprintf(' %f,',str2double(cellData{i,j}) ));
                            else
                                stringCell = strcat(stringCell, sprintf(' %f,',cellData{i,j} ));
                            end
                        else
                            stringCell = strcat(stringCell, sprintf(' ''%s'',',cellData{i,j} ));
                        end
                    end
                    % remove end ,
                    stringCell = stringCell(1:end-1);
                    % add ;
                    stringCell = strcat(stringCell, ' ; ');
                end
                stringCell = strcat(stringCell,'}');            
        end        
    end
    
end
