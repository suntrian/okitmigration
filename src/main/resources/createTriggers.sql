DELIMITER $$

USE `pms_dest`$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tir_task_predecessorlink_before_insert` BEFORE INSERT ON `task_predecessorlink`
    FOR EACH ROW BEGIN
	IF(FIND_IN_SET(new.taskUID,calc_all_predecessortask_id(new.PredecessorUID))>0 && new.type=1)
	THEN
		INSERT INTO `s_task_type`(`id`,`name`,`ord`,`comm`,`is_candelete`,`is_default`) VALUES ( '1','任务出现循环依赖','004','xx','0','0');
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_assessment_applicant_before_delete` BEFORE DELETE ON `assessment_applicant`
    FOR EACH ROW BEGIN
        SET @id = old.id;
        SET @report_id = old.report_id;
        DELETE FROM temp_task WHERE temp_task.Type = 2 AND temp_task.turn_url = CONCAT('openWorkReport.action?applicantID=', @id);
        DELETE FROM assessment_report WHERE assessment_report.id = @report_id;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_assessment_executive_before_delete` BEFORE DELETE ON `assessment_executive`
    FOR EACH ROW BEGIN
        SET @id = old.id;
        DELETE FROM assessment_record WHERE assessment_record.assessment_executive = @id;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_assessment_record_before_delete` BEFORE DELETE ON `assessment_record`
    FOR EACH ROW BEGIN
        SET @id = old.id;
        DELETE FROM temp_task WHERE temp_task.Type = 2 AND temp_task.turn_url = CONCAT('performanceExam.action?assessmentID=', @id);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_format_item_edition_after_insert` AFTER INSERT ON `format_item_edition`
    FOR EACH ROW BEGIN
  DECLARE docEditionUid VARCHAR (32) ;
  SELECT
    format_edition.uid INTO docEditionUid
  FROM
    format_edition
  WHERE format_edition.doc_uid = new.doc_uid
    AND format_edition.is_current = 1 ;
  IF docEditionUid IS NOT NULL
  THEN
  UPDATE
    r_format_section_item
  SET
    altered_status_id = 2
  WHERE doc_edition_uid = docEditionUid
    AND item_uid = new.uid
    AND item_edition = new.edition ;

  /*记录历史*/
  INSERT INTO `format_item_modify_history` (
    `uid`,
    `edition`,
    `doc_uid`,
    `preview_content`,
    `content`,
    `tag`,
    `create_time`,
    `is_current`,
    `project_id`,
    `operator_id`,
    `operate_time`
  )
  VALUES
    (
      new.uid,
      new.edition,
      new.doc_uid,
      new.preview_content,
      new.content,
      new.tag,
      new.create_time,
      new.is_current,
      new.project_id,
      new.operator_id,
      new.operate_time
    ) ;
  END IF ;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_format_item_edition_after_update` AFTER UPDATE ON `format_item_edition`
    FOR EACH ROW BEGIN
  DECLARE docEditionUid VARCHAR(32);
  /*标题或内容变化*/
  IF new.content<>old.content  || new.preview_content<>old.preview_content THEN
  SELECT  format_edition.uid INTO docEditionUid FROM format_edition WHERE format_edition.doc_uid=new.doc_uid AND format_edition.is_current=1;
  UPDATE r_format_section_item SET altered_status_id=2 WHERE doc_edition_uid=docEditionUid AND item_uid=new.uid;

  /*记录历史*/
  INSERT INTO `format_item_modify_history` (
    `uid`,
    `edition`,
    `doc_uid`,
    `preview_content`,
    `content`,
    `tag`,
    `create_time`,
    `is_current`,
    `project_id`,
    `operator_id`,
    `operate_time`
  )
  VALUES
    (
      new.uid,
      new.edition,
      new.doc_uid,
      new.preview_content,
      new.content,
      new.tag,
      new.create_time,
      new.is_current,
      new.project_id,
      new.operator_id,
      new.operate_time
    ) ;
  END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_project_after_update` AFTER UPDATE ON `project`
    FOR EACH ROW BEGIN
		IF(old.is_deleted=0 && new.is_deleted=1) THEN
			UPDATE task SET task.status=7 WHERE task.project_id=old.id AND task.status<>5;
		END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_project_event_after_insert` AFTER INSERT ON `memorabilia`
    FOR EACH ROW BEGIN
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
	VALUES (new.id,'15',NOW(),new.user_id,new.title,0,2);
	IF(new.content IS NOT NULL) THEN
		IF(new.content!='')THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
			VALUES (new.id,'17',NOW(),new.user_id,new.content,0,2);
		END IF;
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_project_event_after_update` AFTER UPDATE ON `memorabilia`
    FOR EACH ROW BEGIN
	IF(new.title!=old.title) THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
		VALUES (old.id,'15',NOW(),old.user_id,old.title,1,2);
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
		VALUES (new.id,'15',NOW(),new.user_id,new.title,0,2);
	END IF;
	IF(new.content!=old.content) THEN
		IF(old.content!='')THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
			VALUES (old.id,'17',NOW(),old.user_id,old.content,1,2);
		END IF;
		IF(new.content!='')THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
			VALUES (new.id,'17',NOW(),new.user_id,new.content,0,2);
		END IF;
	END IF;
    END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_project_init_after_insert` AFTER INSERT ON `project`
    FOR EACH ROW BEGIN
		DECLARE productUid VARCHAR(32);
 		SELECT     REPLACE(UUID(),'-','') INTO productUid FROM DUAL;
		INSERT INTO product (product_uid,NAME,tag,ORD,pm_person_id,creator_id,create_time,level_id,is_default,is_deleted,is_share,type_id)
		VALUES (productUid,new.name,'PDT',1000,new.create_userid,new.create_userid,new.create_date,1,0,0,0,1);
		INSERT INTO r_product_project(product_uid,project_id,is_owned)
		VALUES (productUid,new.id,1);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_question_category_after_insert` AFTER INSERT ON `s_question_category`
    FOR EACH ROW BEGIN
		DECLARE workflowUid VARCHAR(32);
 		SELECT   uid  INTO workflowUid FROM workflow WHERE config_id=3 AND is_default=1;
	            INSERT INTO r_question_category_workflow(category_id,workflow_uid)
		    VALUES (new.id,workflowUid);

END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_format_itemfile_before_delete` BEFORE DELETE ON `r_format_itemfile`
    FOR EACH ROW BEGIN
	DECLARE haveRecord TINYINT DEFAULT 0;

		SELECT 1 INTO haveRecord FROM format_item_statistics
			WHERE format_item_statistics.doc_edition_uid = old.doc_edition_uid
			AND format_item_statistics.item_uid = old.item_uid
			AND format_item_statistics.item_edition  = old.edition;

		IF haveRecord>0 THEN /*已经有记录*/
			UPDATE format_item_statistics
				SET format_item_statistics.attachment_sum = format_item_statistics.attachment_sum-1
			WHERE format_item_statistics.doc_edition_uid = old.doc_edition_uid
				AND format_item_statistics.item_uid = old.item_uid
				AND format_item_statistics.item_edition  = old.edition;
		END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_format_items_after_delete` AFTER DELETE ON `r_format_items`
    FOR EACH ROW BEGIN
    	DECLARE haveRecord TINYINT DEFAULT 0;
		/*首先更新被引用数*/
		SELECT 1 INTO haveRecord FROM format_item_statistics
			WHERE format_item_statistics.doc_edition_uid = old.referencedby_doc_edition_uid
			AND format_item_statistics.item_uid = old.referencedby_item_uid
			AND format_item_statistics.item_edition  = old.referencedby_edition;

		IF haveRecord>0 THEN /*有记录*/
			UPDATE format_item_statistics
				SET format_item_statistics.be_referenced_sum = format_item_statistics.be_referenced_sum-1
			WHERE format_item_statistics.doc_edition_uid = old.referencedby_doc_edition_uid
				AND format_item_statistics.item_uid = old.referencedby_item_uid
				AND format_item_statistics.item_edition  = old.referencedby_edition;
		END IF;

		/*然后处理引用数*/
		SET haveRecord =0;
		SELECT 1 INTO haveRecord FROM format_item_statistics
			WHERE format_item_statistics.doc_edition_uid = old.reference_doc_edition_uid
			AND format_item_statistics.item_uid = old.reference_item_uid
			AND format_item_statistics.item_edition  = old.reference_edition;
		IF haveRecord>0 THEN /*有记录*/
			UPDATE format_item_statistics
				SET format_item_statistics.reference_sum = format_item_statistics.reference_sum-1
			WHERE format_item_statistics.doc_edition_uid = old.reference_doc_edition_uid
				AND format_item_statistics.item_uid 	=  old.reference_item_uid
				AND format_item_statistics.item_edition  = old.reference_edition;
		END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_format_items_after_insert` AFTER INSERT ON `r_format_items`
    FOR EACH ROW BEGIN
		DECLARE haveRecord TINYINT DEFAULT 0;

		/*首先更新被引用数*/
		SELECT 1 INTO haveRecord FROM format_item_statistics
			WHERE format_item_statistics.doc_edition_uid = new.referencedby_doc_edition_uid
			AND format_item_statistics.item_uid = new.referencedby_item_uid
			AND format_item_statistics.item_edition  = new.referencedby_edition;

		IF haveRecord>0 THEN /*已经有记录*/
			UPDATE format_item_statistics
				SET format_item_statistics.be_referenced_sum = format_item_statistics.be_referenced_sum+1
			WHERE format_item_statistics.doc_edition_uid = new.referencedby_doc_edition_uid
				AND format_item_statistics.item_uid = new.referencedby_item_uid
				AND format_item_statistics.item_edition  = new.referencedby_edition;
		ELSE  /*之前没有记录，插入新记录*/
			INSERT INTO format_item_statistics(format_item_statistics.doc_uid
				,format_item_statistics.doc_edition_uid
				,format_item_statistics.item_uid
				,format_item_statistics.item_edition
				,format_item_statistics.reference_sum
				,format_item_statistics.be_referenced_sum
				,format_item_statistics.attachment_sum)
				VALUES
				(new.referencedby_doc_uid
				,new.referencedby_doc_edition_uid
				,new.referencedby_item_uid
				,new.referencedby_edition
				,0
				,1
				,0);
		END IF;

		/*然后处理引用数*/
		SET haveRecord =0;
		SELECT 1 INTO haveRecord FROM format_item_statistics
			WHERE format_item_statistics.doc_edition_uid = new.reference_doc_edition_uid
			AND format_item_statistics.item_uid = new.reference_item_uid
			AND format_item_statistics.item_edition  = new.reference_edition;
		IF haveRecord>0 THEN /*已经有记录*/
			UPDATE format_item_statistics
				SET format_item_statistics.reference_sum = format_item_statistics.reference_sum+1
			WHERE format_item_statistics.doc_edition_uid = new.reference_doc_edition_uid
				AND format_item_statistics.item_uid 	=  new.reference_item_uid
				AND format_item_statistics.item_edition  = new.reference_edition;
		ELSE
			INSERT INTO format_item_statistics(format_item_statistics.doc_uid
				,format_item_statistics.doc_edition_uid
				,format_item_statistics.item_uid
				,format_item_statistics.item_edition
				,format_item_statistics.reference_sum
				,format_item_statistics.be_referenced_sum
				,format_item_statistics.attachment_sum)
				VALUES
				(new.reference_doc_uid
				,new.reference_doc_edition_uid
				,new.reference_item_uid
				,new.reference_edition
				,1
				,0
				,0);
		END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_format_section_item_after_insert` AFTER INSERT ON `r_format_section_item`
    FOR EACH ROW BEGIN
  DECLARE beCurrentEdition TINYINT DEFAULT 0 ;
  SELECT
    format_edition.is_current INTO beCurrentEdition
  FROM
    format_edition
  WHERE format_edition.uid = new.doc_edition_uid ;
  /*只有当前版本才需要更新节次条目数量*/
  IF(beCurrentEdition)
  THEN
  UPDATE
    format_section
  SET
    format_section.self_item_sum = format_section.self_item_sum + 1
  WHERE format_section.edition_uid = new.doc_edition_uid
    AND format_section.uid = new.section_uid ;
  END IF ;
  /*记录历史*/
  IF new.operate_time IS NOT NULL
  THEN
  /*记录条目附件*/
  SELECT
    GROUP_CONCAT(rfif.file_id) INTO @fileIds
  FROM
    r_format_itemfile rfif
  WHERE rfif.item_uid = new.item_uid
    AND rfif.doc_edition_uid = new.doc_edition_uid ;
  INSERT INTO `format_item_dispose_history` (
    `section_uid`,
    `doc_edition_uid`,
    `item_uid`,
    `item_edition`,
    `ord`,
    `priority`,
    `item_type_id`,
    `approve_time`,
    `approver`,
    `create_time`,
    `creator`,
    `status`,
    `is_test`,
    `change_type`,
    `ext_content`,
    `product_uid`,
    `product_version_uid`,
    `module_uid`,
    `alter_operator`,
    `alter_datetime`,
    `changed_record_uid`,
    `altered_status_id`,
    `be_influenced`,
    `is_deleted`,
    `delete_person_id`,
    `delete_date`,
    `scale`,
    `actual_workload`,
    `plan_complete_node`,
    `manager`,
    `tenderer`,
    `stability_id`,
    `difficulty_id`,
    `expected_level_id`,
    `item_source`,
    `file_ids`,
    `operator_id`,
    `operate_time`,
     `INT_COLUMN_1`,
     `INT_COLUMN_2`,
     `INT_COLUMN_3`,
     `INT_COLUMN_4`,
     `INT_COLUMN_5`,
     `INT_COLUMN_6`,
     `INT_COLUMN_7`,
     `INT_COLUMN_8`,
     `INT_COLUMN_9`,
     `INT_COLUMN_10`,
     `INT_COLUMN_11`,
     `INT_COLUMN_12`,
     `INT_COLUMN_13`,
     `INT_COLUMN_14`,
     `INT_COLUMN_15`,
      `MUTILVARCHAR_COLUMN_1` ,
      `MUTILVARCHAR_COLUMN_2` ,
      `MUTILVARCHAR_COLUMN_3`,
      `MUTILVARCHAR_COLUMN_4`,
      `MUTILVARCHAR_COLUMN_5`,
      `MUTILVARCHAR_COLUMN_6` ,
      `MUTILVARCHAR_COLUMN_7`,
      `MUTILVARCHAR_COLUMN_8` ,
      `MUTILVARCHAR_COLUMN_9`,
      `MUTILVARCHAR_COLUMN_10`,

      `DATENOTIME_COLUMN_1` ,
      `DATENOTIME_COLUMN_2` ,
      `DATENOTIME_COLUMN_3` ,
      `DATENOTIME_COLUMN_4` ,
      `DATENOTIME_COLUMN_5` ,
      `DATENOTIME_COLUMN_6` ,
      `DATENOTIME_COLUMN_7` ,
      `DATENOTIME_COLUMN_8` ,
      `DATENOTIME_COLUMN_9` ,
      `DATENOTIME_COLUMN_10` ,

      `SINGLEPERSON_COLUMN_1` ,
      `SINGLEPERSON_COLUMN_2` ,
      `SINGLEPERSON_COLUMN_3` ,
      `SINGLEPERSON_COLUMN_4` ,
      `SINGLEPERSON_COLUMN_5` ,
      `SINGLEPERSON_COLUMN_6` ,
      `SINGLEPERSON_COLUMN_7` ,
      `SINGLEPERSON_COLUMN_8` ,
      `SINGLEPERSON_COLUMN_9`,
      `SINGLEPERSON_COLUMN_10`,


     `DOUBLE_COLUMN_1`,
     `DOUBLE_COLUMN_2`,
     `DOUBLE_COLUMN_3`,
     `DOUBLE_COLUMN_4`,
     `DOUBLE_COLUMN_5`,
     `DOUBLE_COLUMN_6`,
     `DOUBLE_COLUMN_7`,
     `DOUBLE_COLUMN_8`,
     `DOUBLE_COLUMN_9`,
     `DOUBLE_COLUMN_10`,
     `DATE_COLUMN_1`,
     `DATE_COLUMN_2`,
     `DATE_COLUMN_3`,
     `DATE_COLUMN_4`,
     `DATE_COLUMN_5`,
     `DATE_COLUMN_6`,
     `DATE_COLUMN_7`,
     `DATE_COLUMN_8`,
     `DATE_COLUMN_9`,
     `DATE_COLUMN_10`,
     `VARCHAR_COLUMN_1`,
     `VARCHAR_COLUMN_2`,
     `VARCHAR_COLUMN_3`,
     `VARCHAR_COLUMN_4`,
     `VARCHAR_COLUMN_5`,
     `VARCHAR_COLUMN_6`,
     `VARCHAR_COLUMN_7`,
     `VARCHAR_COLUMN_8`,
     `VARCHAR_COLUMN_9`,
     `VARCHAR_COLUMN_10`,
     `TEXT_COLUMN_1`,
     `TEXT_COLUMN_2`,
     `TEXT_COLUMN_3`,
     `BOOLEAN_COLUMN_1`,
     `BOOLEAN_COLUMN_2`,
     `BOOLEAN_COLUMN_3`,
     `BOOLEAN_COLUMN_4`,
     `BOOLEAN_COLUMN_5`,
     `HREF_COLUMN_1`,
     `HREF_COLUMN_2`,
     `HREF_COLUMN_3`,
     `HREF_COLUMN_4`,
     `HREF_COLUMN_5`,
     `HREF_COLUMN_1_NAME`,
     `HREF_COLUMN_2_NAME`,
     `HREF_COLUMN_3_NAME`,
     `HREF_COLUMN_4_NAME`,
     `HREF_COLUMN_5_NAME`,
     `STANDARD_COLUMN_1`,
     `STANDARD_COLUMN_2`,
     `STANDARD_COLUMN_3`,
     `STANDARD_COLUMN_4`,
     `STANDARD_COLUMN_5`
  )
  VALUES
    (
      new.section_uid,
      new.doc_edition_uid,
      new.item_uid,
      new.item_edition,
      new.ord,
      new.priority,
      new.item_type_id,
      new.approve_time,
      new.approver,
      new.create_time,
      new.creator,
      new.status,
      new.is_test,
      new.change_type,
      new.ext_content,
      new.product_uid,
      new.product_version_uid,
      new.module_uid,
      new.alter_operator,
      new.alter_datetime,
      new.changed_record_uid,
      new.altered_status_id,
      new.be_influenced,
      new.is_deleted,
      new.delete_person_id,
      new.delete_date,
      new.scale,
      new.actual_workload,
      new.plan_complete_node,
      new.manager,
      new.tenderer,
      new.stability_id,
      new.difficulty_id,
      new.expected_level_id,
      new.item_source,
      @fileIds,
      new.operator_id,
      new.operate_time,
      new.INT_COLUMN_1,
      new.INT_COLUMN_2,
      new.INT_COLUMN_3,
      new.INT_COLUMN_4,
      new.INT_COLUMN_5,
      new.INT_COLUMN_6,
      new.INT_COLUMN_7,
      new.INT_COLUMN_8,
      new.INT_COLUMN_9,
      new.INT_COLUMN_10,
      new.`INT_COLUMN_11`,
new.`INT_COLUMN_12` ,
new.`INT_COLUMN_13` ,
new.`INT_COLUMN_14` ,
new.`INT_COLUMN_15` ,
new.`MUTILVARCHAR_COLUMN_1`,
new.`MUTILVARCHAR_COLUMN_2` ,
new.`MUTILVARCHAR_COLUMN_3` ,
new.`MUTILVARCHAR_COLUMN_4`,
new.`MUTILVARCHAR_COLUMN_5`,
new.`MUTILVARCHAR_COLUMN_6` ,
new.`MUTILVARCHAR_COLUMN_7`,
new.`MUTILVARCHAR_COLUMN_8` ,
new.`MUTILVARCHAR_COLUMN_9`,
new.`MUTILVARCHAR_COLUMN_10`,

new.`DATENOTIME_COLUMN_1` ,
new.`DATENOTIME_COLUMN_2` ,
new.`DATENOTIME_COLUMN_3` ,
new.`DATENOTIME_COLUMN_4` ,
new.`DATENOTIME_COLUMN_5` ,
new.`DATENOTIME_COLUMN_6` ,
new.`DATENOTIME_COLUMN_7` ,
new.`DATENOTIME_COLUMN_8` ,
new.`DATENOTIME_COLUMN_9` ,
new.`DATENOTIME_COLUMN_10`,

new.`SINGLEPERSON_COLUMN_1` ,
new.`SINGLEPERSON_COLUMN_2` ,
new.`SINGLEPERSON_COLUMN_3` ,
new.`SINGLEPERSON_COLUMN_4` ,
new.`SINGLEPERSON_COLUMN_5` ,
new.`SINGLEPERSON_COLUMN_6` ,
new.`SINGLEPERSON_COLUMN_7` ,
new.`SINGLEPERSON_COLUMN_8` ,
new.`SINGLEPERSON_COLUMN_9`,
new.`SINGLEPERSON_COLUMN_10`,
      new.DOUBLE_COLUMN_1,
      new.DOUBLE_COLUMN_2,
      new.DOUBLE_COLUMN_3,
      new.DOUBLE_COLUMN_4,
      new.DOUBLE_COLUMN_5,
      new.DOUBLE_COLUMN_6,
      new.DOUBLE_COLUMN_7,
      new.DOUBLE_COLUMN_8,
      new.DOUBLE_COLUMN_9,
      new.DOUBLE_COLUMN_10,
      new.DATE_COLUMN_1,
      new.DATE_COLUMN_2,
      new.DATE_COLUMN_3,
      new.DATE_COLUMN_4,
      new.DATE_COLUMN_5,
      new.DATE_COLUMN_6,
      new.DATE_COLUMN_7,
      new.DATE_COLUMN_8,
      new.DATE_COLUMN_9,
      new.DATE_COLUMN_10,
      new.VARCHAR_COLUMN_1,
      new.VARCHAR_COLUMN_2,
      new.VARCHAR_COLUMN_3,
      new.VARCHAR_COLUMN_4,
      new.VARCHAR_COLUMN_5,
      new.VARCHAR_COLUMN_6,
      new.VARCHAR_COLUMN_7,
      new.VARCHAR_COLUMN_8,
      new.VARCHAR_COLUMN_9,
      new.VARCHAR_COLUMN_10,
      new.TEXT_COLUMN_1,
      new.TEXT_COLUMN_2,
      new.TEXT_COLUMN_3,
      new.BOOLEAN_COLUMN_1,
      new.BOOLEAN_COLUMN_2,
      new.BOOLEAN_COLUMN_3,
      new.BOOLEAN_COLUMN_4,
      new.BOOLEAN_COLUMN_5,
      new.HREF_COLUMN_1,
      new.HREF_COLUMN_2,
      new.HREF_COLUMN_3,
      new.HREF_COLUMN_4,
      new.HREF_COLUMN_5,
      new.HREF_COLUMN_1_NAME,
      new.HREF_COLUMN_2_NAME,
      new.HREF_COLUMN_3_NAME,
      new.HREF_COLUMN_4_NAME,
      new.HREF_COLUMN_5_NAME,
      new.STANDARD_COLUMN_1,
      new.STANDARD_COLUMN_2,
      new.STANDARD_COLUMN_3,
      new.STANDARD_COLUMN_4,
      new.STANDARD_COLUMN_5

    ) ;
  END IF ;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_format_section_item_after_update` AFTER UPDATE ON `r_format_section_item`
    FOR EACH ROW BEGIN
  /*删除条目关联
    DELETE
    FROM r_format_items
    WHERE (reference_edition = old.item_edition
           AND reference_item_uid = old.item_uid
           AND reference_doc_edition_uid = old.doc_edition_uid)
         OR (referencedby_edition = old.item_edition
         AND referencedby_item_uid = old.item_uid
         AND reference_doc_edition_uid = old.doc_edition_uid);*/
  DECLARE del_section_uid VARCHAR (32) ;
  /*删除情况*/
  IF new.is_deleted = 1 && old.is_deleted = 0
  THEN
  /*对应节次条目数减一*/
  UPDATE
    format_section
  SET
    format_section.self_item_sum = format_section.self_item_sum - 1
  WHERE format_section.edition_uid = old.doc_edition_uid
    AND format_section.uid = old.section_uid ;
  /*恢复*/
  ELSEIF new.is_deleted = 0 && old.is_deleted = 1
  THEN
  /*对应节次条目数加一*/
  UPDATE
    format_section
  SET
    format_section.self_item_sum = format_section.self_item_sum + 1
  WHERE format_section.edition_uid = new.doc_edition_uid
    AND format_section.uid = new.section_uid ;
  /*剪切情况*/
  ELSEIF new.section_uid <> old.section_uid
  THEN
  UPDATE
    format_section
  SET
    format_section.self_item_sum = format_section.self_item_sum - 1
  WHERE format_section.edition_uid = old.doc_edition_uid
    AND format_section.uid = old.section_uid ;
  UPDATE
    format_section
  SET
    format_section.self_item_sum = format_section.self_item_sum + 1
  WHERE format_section.edition_uid = old.doc_edition_uid
    AND format_section.uid = new.section_uid ;
  END IF ;
  /*记录历史*/
  SET @flag = 0 ;
  /*优先级变化*/
  IF IFNULL(
    new.priority <> old.priority,
    ! (new.priority <=> old.priority)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*条目类型变化*/
  IF IFNULL(
    new.item_type_id <> old.item_type_id,
    ! (
      new.item_type_id <=> old.item_type_id
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*批准人变化*/
  IF IFNULL(
    new.approver <> old.approver,
    ! (new.approver <=> old.approver)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*拟制人变化*/
  IF IFNULL(
    new.creator <> old.creator,
    ! (new.creator <=> old.creator)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*状态变化*/
  IF IFNULL(
    new.status <> old.status,
    ! (new.status <=> old.status)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*是否可测变化*/
  IF IFNULL(
    new.is_test <> old.is_test,
    ! (new.is_test <=> old.is_test)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*产品变化*/
  IF IFNULL(
    new.product_uid <> old.product_uid,
    ! (
      new.product_uid <=> old.product_uid
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*产品版本变化*/
  IF IFNULL(
    new.product_version_uid <> old.product_version_uid,
    ! (
      new.product_version_uid <=> old.product_version_uid
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*模块变化*/
  IF IFNULL(
    new.module_uid <> old.module_uid,
    ! (
      new.module_uid <=> old.module_uid
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*变更依据变化*/
  IF IFNULL(
    new.changed_record_uid <> old.changed_record_uid,
    ! (
      new.changed_record_uid <=> old.changed_record_uid
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*条目删除*/
  IF new.is_deleted <> old.is_deleted
  THEN SET @flag = 1 ;
  END IF ;
  /*规模变化*/
  IF IFNULL(
    new.scale <> old.scale,
    ! (new.scale <=> old.scale)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*工作量变化*/
  IF IFNULL(
    new.actual_workload <> old.actual_workload,
    ! (
      new.actual_workload <=> old.actual_workload
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*里程碑变化*/
  IF IFNULL(
    new.plan_complete_node <> old.plan_complete_node,
    ! (
      new.plan_complete_node <=> old.plan_complete_node
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*负责人变化*/
  IF IFNULL(
    new.manager <> old.manager,
    ! (new.manager <=> old.manager)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*提出人变化*/
  IF IFNULL(
    new.tenderer <> old.tenderer,
    ! (new.tenderer <=> old.tenderer)
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*稳定程度变化*/
  IF IFNULL(
    new.stability_id <> old.stability_id,
    ! (
      new.stability_id <=> old.stability_id
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*难度变化*/
  IF IFNULL(
    new.difficulty_id <> old.difficulty_id,
    ! (
      new.difficulty_id <=> old.difficulty_id
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*期望等级变化*/
  IF IFNULL(
    new.expected_level_id <> old.expected_level_id,
    ! (
      new.expected_level_id <=> old.expected_level_id
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*来源变化*/
  IF IFNULL(
    new.item_source <> old.item_source,
    ! (
      new.item_source <=> old.item_source
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*确认变更和取消疑似变更*/
  IF new.altered_status_id <> 2 && IFNULL(
    new.altered_status_id <> old.altered_status_id,
    ! (
      new.altered_status_id <=> old.altered_status_id
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*判断操作时间*/
  IF new.operate_time IS NOT NULL && IFNULL(new.operate_time <> old.operate_time, TRUE)
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_1 <> old.INT_COLUMN_1,
    ! (
      new.INT_COLUMN_1 <=> old.INT_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_2 <> old.INT_COLUMN_2,
    ! (
      new.INT_COLUMN_2 <=> old.INT_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_3 <> old.INT_COLUMN_3,
    ! (
      new.INT_COLUMN_3 <=> old.INT_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_4 <> old.INT_COLUMN_4,
    ! (
      new.INT_COLUMN_4 <=> old.INT_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_5 <> old.INT_COLUMN_5,
    ! (
      new.INT_COLUMN_5 <=> old.INT_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_6 <> old.INT_COLUMN_6,
    ! (
      new.INT_COLUMN_6 <=> old.INT_COLUMN_6
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_7 <> old.INT_COLUMN_7,
    ! (
      new.INT_COLUMN_7 <=> old.INT_COLUMN_7
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_8 <> old.INT_COLUMN_8,
    ! (
      new.INT_COLUMN_8 <=> old.INT_COLUMN_8
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_9 <> old.INT_COLUMN_9,
    ! (
      new.INT_COLUMN_9 <=> old.INT_COLUMN_9
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_10 <> old.INT_COLUMN_10,
    ! (
      new.INT_COLUMN_10 <=> old.INT_COLUMN_10
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_11 <> old.INT_COLUMN_11,
    ! (
      new.INT_COLUMN_11 <=> old.INT_COLUMN_11
    )
  )
  THEN SET @flag = 1 ;
  END IF ;

  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_12 <> old.INT_COLUMN_12,
    ! (
      new.INT_COLUMN_12 <=> old.INT_COLUMN_12
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_13 <> old.INT_COLUMN_13,
    ! (
      new.INT_COLUMN_13 <=> old.INT_COLUMN_13
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
/*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_14 <> old.INT_COLUMN_14,
    ! (
      new.INT_COLUMN_14 <=> old.INT_COLUMN_14
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.INT_COLUMN_15 <> old.INT_COLUMN_15,
    ! (
      new.INT_COLUMN_15 <=> old.INT_COLUMN_15
    )
  )
  THEN SET @flag = 1 ;
  END IF ;


  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_1 <> old.MUTILVARCHAR_COLUMN_1,
    ! (
      new.MUTILVARCHAR_COLUMN_1 <=> old.MUTILVARCHAR_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_2 <> old.MUTILVARCHAR_COLUMN_2,
    ! (
      new.MUTILVARCHAR_COLUMN_2 <=> old.MUTILVARCHAR_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_3 <> old.MUTILVARCHAR_COLUMN_3,
    ! (
      new.MUTILVARCHAR_COLUMN_3 <=> old.MUTILVARCHAR_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_4 <> old.MUTILVARCHAR_COLUMN_4,
    ! (
      new.MUTILVARCHAR_COLUMN_4 <=> old.MUTILVARCHAR_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_5 <> old.MUTILVARCHAR_COLUMN_5,
    ! (
      new.MUTILVARCHAR_COLUMN_5 <=> old.MUTILVARCHAR_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_6 <> old.MUTILVARCHAR_COLUMN_6,
    ! (
      new.MUTILVARCHAR_COLUMN_6 <=> old.MUTILVARCHAR_COLUMN_6
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_7 <> old.MUTILVARCHAR_COLUMN_7,
    ! (
      new.MUTILVARCHAR_COLUMN_7 <=> old.MUTILVARCHAR_COLUMN_7
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_8 <> old.MUTILVARCHAR_COLUMN_8,
    ! (
      new.MUTILVARCHAR_COLUMN_8 <=> old.MUTILVARCHAR_COLUMN_8
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_9 <> old.MUTILVARCHAR_COLUMN_9,
    ! (
      new.MUTILVARCHAR_COLUMN_9 <=> old.MUTILVARCHAR_COLUMN_9
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.MUTILVARCHAR_COLUMN_10 <> old.MUTILVARCHAR_COLUMN_10,
    ! (
      new.MUTILVARCHAR_COLUMN_10 <=> old.MUTILVARCHAR_COLUMN_10
    )
  )
  THEN SET @flag = 1 ;
  END IF ;

    /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_1 <> old.DATENOTIME_COLUMN_1,
    ! (
      new.DATENOTIME_COLUMN_1 <=> old.DATENOTIME_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_2 <> old.DATENOTIME_COLUMN_2,
    ! (
      new.DATENOTIME_COLUMN_2 <=> old.DATENOTIME_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_3 <> old.DATENOTIME_COLUMN_3,
    ! (
      new.DATENOTIME_COLUMN_3 <=> old.DATENOTIME_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_4 <> old.DATENOTIME_COLUMN_4,
    ! (
      new.DATENOTIME_COLUMN_4 <=> old.DATENOTIME_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_5 <> old.DATENOTIME_COLUMN_5,
    ! (
      new.DATENOTIME_COLUMN_5 <=> old.DATENOTIME_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_6 <> old.DATENOTIME_COLUMN_6,
    ! (
      new.DATENOTIME_COLUMN_6 <=> old.DATENOTIME_COLUMN_6
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_7 <> old.DATENOTIME_COLUMN_7,
    ! (
      new.DATENOTIME_COLUMN_7 <=> old.DATENOTIME_COLUMN_7
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_8 <> old.DATENOTIME_COLUMN_8,
    ! (
      new.DATENOTIME_COLUMN_8 <=> old.DATENOTIME_COLUMN_8
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_9 <> old.DATENOTIME_COLUMN_9,
    ! (
      new.DATENOTIME_COLUMN_9 <=> old.DATENOTIME_COLUMN_9
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DATENOTIME_COLUMN_10 <> old.DATENOTIME_COLUMN_10,
    ! (
      new.DATENOTIME_COLUMN_10 <=> old.DATENOTIME_COLUMN_10
    )
  )
  THEN SET @flag = 1 ;
  END IF ;

      /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_1 <> old.SINGLEPERSON_COLUMN_1,
    ! (
      new.SINGLEPERSON_COLUMN_1 <=> old.SINGLEPERSON_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_2 <> old.SINGLEPERSON_COLUMN_2,
    ! (
      new.SINGLEPERSON_COLUMN_2 <=> old.SINGLEPERSON_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_3 <> old.SINGLEPERSON_COLUMN_3,
    ! (
      new.SINGLEPERSON_COLUMN_3 <=> old.SINGLEPERSON_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_4 <> old.SINGLEPERSON_COLUMN_4,
    ! (
      new.SINGLEPERSON_COLUMN_4 <=> old.SINGLEPERSON_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_5 <> old.SINGLEPERSON_COLUMN_5,
    ! (
      new.SINGLEPERSON_COLUMN_5 <=> old.SINGLEPERSON_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_6 <> old.SINGLEPERSON_COLUMN_6,
    ! (
      new.SINGLEPERSON_COLUMN_6 <=> old.SINGLEPERSON_COLUMN_6
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_7 <> old.SINGLEPERSON_COLUMN_7,
    ! (
      new.SINGLEPERSON_COLUMN_7 <=> old.SINGLEPERSON_COLUMN_7
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_8 <> old.SINGLEPERSON_COLUMN_8,
    ! (
      new.SINGLEPERSON_COLUMN_8 <=> old.SINGLEPERSON_COLUMN_8
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_9 <> old.SINGLEPERSON_COLUMN_9,
    ! (
      new.SINGLEPERSON_COLUMN_9 <=> old.SINGLEPERSON_COLUMN_9
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.SINGLEPERSON_COLUMN_10 <> old.SINGLEPERSON_COLUMN_10,
    ! (
      new.SINGLEPERSON_COLUMN_10 <=> old.SINGLEPERSON_COLUMN_10
    )
  )
  THEN SET @flag = 1 ;
  END IF ;




  /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_1 <> old.DOUBLE_COLUMN_1,
    ! (
      new.DOUBLE_COLUMN_1 <=> old.DOUBLE_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_2 <> old.DOUBLE_COLUMN_2,
    ! (
      new.DOUBLE_COLUMN_2 <=> old.DOUBLE_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_3 <> old.DOUBLE_COLUMN_3,
    ! (
      new.DOUBLE_COLUMN_3 <=> old.DOUBLE_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_5 <> old.DOUBLE_COLUMN_5,
    ! (
      new.DOUBLE_COLUMN_5 <=> old.DOUBLE_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_6 <> old.DOUBLE_COLUMN_6,
    ! (
      new.DOUBLE_COLUMN_6 <=> old.DOUBLE_COLUMN_6
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_7 <> old.DOUBLE_COLUMN_7,
    ! (
      new.DOUBLE_COLUMN_7 <=> old.DOUBLE_COLUMN_7
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_8 <> old.DOUBLE_COLUMN_8,
    ! (
      new.DOUBLE_COLUMN_8 <=> old.DOUBLE_COLUMN_8
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_9 <> old.DOUBLE_COLUMN_9,
    ! (
      new.DOUBLE_COLUMN_9 <=> old.DOUBLE_COLUMN_9
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_10 <> old.DOUBLE_COLUMN_10,
    ! (
      new.DOUBLE_COLUMN_10 <=> old.DOUBLE_COLUMN_10
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_1 <> old.DATE_COLUMN_1,
    ! (
      new.DATE_COLUMN_1 <=> old.DATE_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_2 <> old.DATE_COLUMN_2,
    ! (
      new.DATE_COLUMN_2 <=> old.DATE_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_3 <> old.DATE_COLUMN_3,
    ! (
      new.DATE_COLUMN_3 <=> old.DATE_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_4 <> old.DATE_COLUMN_4,
    ! (
      new.DATE_COLUMN_4 <=> old.DATE_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_5 <> old.DATE_COLUMN_5,
    ! (
      new.DATE_COLUMN_5 <=> old.DATE_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_6 <> old.DATE_COLUMN_6,
    ! (
      new.DATE_COLUMN_6 <=> old.DATE_COLUMN_6
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_7 <> old.DATE_COLUMN_7,
    ! (
      new.DATE_COLUMN_7 <=> old.DATE_COLUMN_7
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_8 <> old.DATE_COLUMN_8,
    ! (
      new.DATE_COLUMN_8 <=> old.DATE_COLUMN_8
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_9 <> old.DATE_COLUMN_9,
    ! (
      new.DATE_COLUMN_9 <=> old.DATE_COLUMN_9
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DATE_COLUMN_10 <> old.DATE_COLUMN_10,
    ! (
      new.DATE_COLUMN_10 <=> old.DATE_COLUMN_10
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_1 <> old.VARCHAR_COLUMN_1,
    ! (
      new.VARCHAR_COLUMN_1 <=> old.VARCHAR_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_2 <> old.VARCHAR_COLUMN_2,
    ! (
      new.VARCHAR_COLUMN_2 <=> old.VARCHAR_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_3 <> old.VARCHAR_COLUMN_3,
    ! (
      new.VARCHAR_COLUMN_3 <=> old.VARCHAR_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_4 <> old.VARCHAR_COLUMN_4,
    ! (
      new.VARCHAR_COLUMN_4 <=> old.VARCHAR_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_5 <> old.VARCHAR_COLUMN_5,
    ! (
      new.VARCHAR_COLUMN_5 <=> old.VARCHAR_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_6 <> old.VARCHAR_COLUMN_6,
    ! (
      new.VARCHAR_COLUMN_6 <=> old.VARCHAR_COLUMN_6
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_7 <> old.VARCHAR_COLUMN_7,
    ! (
      new.VARCHAR_COLUMN_7 <=> old.VARCHAR_COLUMN_7
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_8 <> old.VARCHAR_COLUMN_8,
    ! (
      new.VARCHAR_COLUMN_8 <=> old.VARCHAR_COLUMN_8
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_9 <> old.VARCHAR_COLUMN_9,
    ! (
      new.VARCHAR_COLUMN_9 <=> old.VARCHAR_COLUMN_9
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.VARCHAR_COLUMN_10 <> old.VARCHAR_COLUMN_10,
    ! (
      new.VARCHAR_COLUMN_10 <=> old.VARCHAR_COLUMN_10
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.TEXT_COLUMN_1 <> old.TEXT_COLUMN_1,
    ! (
      new.TEXT_COLUMN_1 <=> old.TEXT_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.TEXT_COLUMN_2 <> old.TEXT_COLUMN_2,
    ! (
      new.TEXT_COLUMN_2 <=> old.TEXT_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.TEXT_COLUMN_3 <> old.TEXT_COLUMN_3,
    ! (
      new.TEXT_COLUMN_3 <=> old.TEXT_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.BOOLEAN_COLUMN_1 <> old.BOOLEAN_COLUMN_1,
    ! (
      new.BOOLEAN_COLUMN_1 <=> old.BOOLEAN_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.BOOLEAN_COLUMN_2 <> old.BOOLEAN_COLUMN_2,
    ! (
      new.BOOLEAN_COLUMN_2 <=> old.BOOLEAN_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.BOOLEAN_COLUMN_3 <> old.BOOLEAN_COLUMN_3,
    ! (
      new.BOOLEAN_COLUMN_3 <=> old.BOOLEAN_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.BOOLEAN_COLUMN_4 <> old.BOOLEAN_COLUMN_4,
    ! (
      new.BOOLEAN_COLUMN_4 <=> old.BOOLEAN_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.BOOLEAN_COLUMN_5 <> old.BOOLEAN_COLUMN_5,
    ! (
      new.BOOLEAN_COLUMN_5 <=> old.BOOLEAN_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;


   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_1 <> old.HREF_COLUMN_1,
    ! (
      new.HREF_COLUMN_1 <=> old.HREF_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_2 <> old.HREF_COLUMN_2,
    ! (
      new.HREF_COLUMN_2 <=> old.HREF_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_3 <> old.HREF_COLUMN_3,
    ! (
      new.HREF_COLUMN_3 <=> old.HREF_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_4 <> old.HREF_COLUMN_4,
    ! (
      new.HREF_COLUMN_4 <=> old.HREF_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_5 <> old.HREF_COLUMN_5,
    ! (
      new.HREF_COLUMN_5 <=> old.HREF_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;

    /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_1_NAME <> old.HREF_COLUMN_1_NAME,
    ! (
      new.HREF_COLUMN_1_NAME <=> old.HREF_COLUMN_1_NAME
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_2_NAME <> old.HREF_COLUMN_2_NAME,
    ! (
      new.HREF_COLUMN_2_NAME <=> old.HREF_COLUMN_2_NAME
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_3_NAME <> old.HREF_COLUMN_3_NAME,
    ! (
      new.HREF_COLUMN_3_NAME <=> old.HREF_COLUMN_3_NAME
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_4_NAME <> old.HREF_COLUMN_4_NAME,
    ! (
      new.HREF_COLUMN_4_NAME <=> old.HREF_COLUMN_4_NAME
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.HREF_COLUMN_5_NAME <> old.HREF_COLUMN_5_NAME,
    ! (
      new.HREF_COLUMN_5_NAME <=> old.HREF_COLUMN_5_NAME
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.STANDARD_COLUMN_1 <> old.STANDARD_COLUMN_1,
    ! (
      new.STANDARD_COLUMN_1 <=> old.STANDARD_COLUMN_1
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.DOUBLE_COLUMN_4 <> old.DOUBLE_COLUMN_4,
    ! (
      new.DOUBLE_COLUMN_4 <=> old.DOUBLE_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.STANDARD_COLUMN_2 <> old.STANDARD_COLUMN_2,
    ! (
      new.STANDARD_COLUMN_2 <=> old.STANDARD_COLUMN_2
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.STANDARD_COLUMN_3 <> old.STANDARD_COLUMN_3,
    ! (
      new.STANDARD_COLUMN_3 <=> old.STANDARD_COLUMN_3
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.STANDARD_COLUMN_4 <> old.STANDARD_COLUMN_4,
    ! (
      new.STANDARD_COLUMN_4 <=> old.STANDARD_COLUMN_4
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
   /*自定义列*/
  IF IFNULL(
    new.STANDARD_COLUMN_5 <> old.STANDARD_COLUMN_5,
    ! (
      new.STANDARD_COLUMN_5 <=> old.STANDARD_COLUMN_5
    )
  )
  THEN SET @flag = 1 ;
  END IF ;
  /*从删除中恢复的不记录，此为合并文档中的特殊情况：有两次update，这里屏蔽第一次修改删除标记的记录*/
  IF new.is_deleted = 0 && old.is_deleted = 1
  THEN SET @flag = 0 ;
  END IF ;
  IF @flag = 1
  THEN
  /*记录条目附件*/
  SELECT
    GROUP_CONCAT(rfif.file_id) INTO @fileIds
  FROM
    r_format_itemfile rfif
  WHERE rfif.item_uid = new.item_uid
    AND rfif.doc_edition_uid = new.doc_edition_uid ;
  INSERT INTO `format_item_dispose_history` (
    `section_uid`,
    `doc_edition_uid`,
    `item_uid`,
    `item_edition`,
    `ord`,
    `priority`,
    `item_type_id`,
    `approve_time`,
    `approver`,
    `create_time`,
    `creator`,
    `status`,
    `is_test`,
    `change_type`,
    `ext_content`,
    `product_uid`,
    `product_version_uid`,
    `module_uid`,
    `alter_operator`,
    `alter_datetime`,
    `changed_record_uid`,
    `altered_status_id`,
    `be_influenced`,
    `is_deleted`,
    `delete_person_id`,
    `delete_date`,
    `scale`,
    `actual_workload`,
    `plan_complete_node`,
    `manager`,
    `tenderer`,
    `stability_id`,
    `difficulty_id`,
    `expected_level_id`,
    `item_source`,
    `file_ids`,
    `operator_id`,
    `operate_time`,
     `INT_COLUMN_1`,
     `INT_COLUMN_2`,
     `INT_COLUMN_3`,
     `INT_COLUMN_4`,
     `INT_COLUMN_5`,
     `INT_COLUMN_6`,
     `INT_COLUMN_7`,
     `INT_COLUMN_8`,
     `INT_COLUMN_9`,
     `INT_COLUMN_10`,
     `INT_COLUMN_11`,
     `INT_COLUMN_12`,
     `INT_COLUMN_13`,
     `INT_COLUMN_14`,
     `INT_COLUMN_15`,
      `MUTILVARCHAR_COLUMN_1` ,
      `MUTILVARCHAR_COLUMN_2` ,
      `MUTILVARCHAR_COLUMN_3`,
      `MUTILVARCHAR_COLUMN_4`,
      `MUTILVARCHAR_COLUMN_5`,
      `MUTILVARCHAR_COLUMN_6` ,
      `MUTILVARCHAR_COLUMN_7`,
      `MUTILVARCHAR_COLUMN_8` ,
      `MUTILVARCHAR_COLUMN_9`,
      `MUTILVARCHAR_COLUMN_10`,
      `DATENOTIME_COLUMN_1` ,
      `DATENOTIME_COLUMN_2` ,
      `DATENOTIME_COLUMN_3` ,
      `DATENOTIME_COLUMN_4` ,
      `DATENOTIME_COLUMN_5` ,
      `DATENOTIME_COLUMN_6` ,
      `DATENOTIME_COLUMN_7` ,
      `DATENOTIME_COLUMN_8` ,
      `DATENOTIME_COLUMN_9` ,
      `DATENOTIME_COLUMN_10` ,
      `SINGLEPERSON_COLUMN_1` ,
      `SINGLEPERSON_COLUMN_2` ,
      `SINGLEPERSON_COLUMN_3` ,
      `SINGLEPERSON_COLUMN_4` ,
      `SINGLEPERSON_COLUMN_5` ,
      `SINGLEPERSON_COLUMN_6` ,
      `SINGLEPERSON_COLUMN_7` ,
      `SINGLEPERSON_COLUMN_8` ,
      `SINGLEPERSON_COLUMN_9`,
      `SINGLEPERSON_COLUMN_10`,
     `DOUBLE_COLUMN_1`,
     `DOUBLE_COLUMN_2`,
     `DOUBLE_COLUMN_3`,
     `DOUBLE_COLUMN_4`,
     `DOUBLE_COLUMN_5`,
     `DOUBLE_COLUMN_6`,
     `DOUBLE_COLUMN_7`,
     `DOUBLE_COLUMN_8`,
     `DOUBLE_COLUMN_9`,
     `DOUBLE_COLUMN_10`,
     `DATE_COLUMN_1`,
     `DATE_COLUMN_2`,
     `DATE_COLUMN_3`,
     `DATE_COLUMN_4`,
     `DATE_COLUMN_5`,
     `DATE_COLUMN_6`,
     `DATE_COLUMN_7`,
     `DATE_COLUMN_8`,
     `DATE_COLUMN_9`,
     `DATE_COLUMN_10`,
     `VARCHAR_COLUMN_1`,
     `VARCHAR_COLUMN_2`,
     `VARCHAR_COLUMN_3`,
     `VARCHAR_COLUMN_4`,
     `VARCHAR_COLUMN_5`,
     `VARCHAR_COLUMN_6`,
     `VARCHAR_COLUMN_7`,
     `VARCHAR_COLUMN_8`,
     `VARCHAR_COLUMN_9`,
     `VARCHAR_COLUMN_10`,
     `TEXT_COLUMN_1`,
     `TEXT_COLUMN_2`,
     `TEXT_COLUMN_3`,
     `BOOLEAN_COLUMN_1`,
     `BOOLEAN_COLUMN_2`,
     `BOOLEAN_COLUMN_3`,
     `BOOLEAN_COLUMN_4`,
     `BOOLEAN_COLUMN_5`,
     `HREF_COLUMN_1`,
     `HREF_COLUMN_2`,
     `HREF_COLUMN_3`,
     `HREF_COLUMN_4`,
     `HREF_COLUMN_5`,
     `HREF_COLUMN_1_NAME`,
     `HREF_COLUMN_2_NAME`,
     `HREF_COLUMN_3_NAME`,
     `HREF_COLUMN_4_NAME`,
     `HREF_COLUMN_5_NAME`,
     `STANDARD_COLUMN_1`,
     `STANDARD_COLUMN_2`,
     `STANDARD_COLUMN_3`,
     `STANDARD_COLUMN_4`,
     `STANDARD_COLUMN_5`
  )
  VALUES
    (
      new.section_uid,
      new.doc_edition_uid,
      new.item_uid,
      new.item_edition,
      new.ord,
      new.priority,
      new.item_type_id,
      new.approve_time,
      new.approver,
      new.create_time,
      new.creator,
      new.status,
      new.is_test,
      new.change_type,
      new.ext_content,
      new.product_uid,
      new.product_version_uid,
      new.module_uid,
      new.alter_operator,
      new.alter_datetime,
      new.changed_record_uid,
      new.altered_status_id,
      new.be_influenced,
      new.is_deleted,
      new.delete_person_id,
      new.delete_date,
      new.scale,
      new.actual_workload,
      new.plan_complete_node,
      new.manager,
      new.tenderer,
      new.stability_id,
      new.difficulty_id,
      new.expected_level_id,
      new.item_source,
      @fileIds,
      new.operator_id,
      new.operate_time,
      new.INT_COLUMN_1,
      new.INT_COLUMN_2,
      new.INT_COLUMN_3,
      new.INT_COLUMN_4,
      new.INT_COLUMN_5,
      new.INT_COLUMN_6,
      new.INT_COLUMN_7,
      new.INT_COLUMN_8,
      new.INT_COLUMN_9,
      new.INT_COLUMN_10,
      new.`INT_COLUMN_11`,
new.`INT_COLUMN_12` ,
new.`INT_COLUMN_13` ,
new.`INT_COLUMN_14` ,
new.`INT_COLUMN_15` ,
new.`MUTILVARCHAR_COLUMN_1`,
new.`MUTILVARCHAR_COLUMN_2` ,
new.`MUTILVARCHAR_COLUMN_3` ,
new.`MUTILVARCHAR_COLUMN_4`,
new.`MUTILVARCHAR_COLUMN_5`,
new.`MUTILVARCHAR_COLUMN_6` ,
new.`MUTILVARCHAR_COLUMN_7`,
new.`MUTILVARCHAR_COLUMN_8` ,
new.`MUTILVARCHAR_COLUMN_9`,
new.`MUTILVARCHAR_COLUMN_10`,
new.`DATENOTIME_COLUMN_1` ,
new.`DATENOTIME_COLUMN_2` ,
new.`DATENOTIME_COLUMN_3` ,
new.`DATENOTIME_COLUMN_4` ,
new.`DATENOTIME_COLUMN_5` ,
new.`DATENOTIME_COLUMN_6` ,
new.`DATENOTIME_COLUMN_7` ,
new.`DATENOTIME_COLUMN_8` ,
new.`DATENOTIME_COLUMN_9` ,
new.`DATENOTIME_COLUMN_10`,
new.`SINGLEPERSON_COLUMN_1` ,
new.`SINGLEPERSON_COLUMN_2` ,
new.`SINGLEPERSON_COLUMN_3` ,
new.`SINGLEPERSON_COLUMN_4` ,
new.`SINGLEPERSON_COLUMN_5` ,
new.`SINGLEPERSON_COLUMN_6` ,
new.`SINGLEPERSON_COLUMN_7` ,
new.`SINGLEPERSON_COLUMN_8` ,
new.`SINGLEPERSON_COLUMN_9`,
new.`SINGLEPERSON_COLUMN_10`,
      new.DOUBLE_COLUMN_1,
      new.DOUBLE_COLUMN_2,
      new.DOUBLE_COLUMN_3,
      new.DOUBLE_COLUMN_4,
      new.DOUBLE_COLUMN_5,
      new.DOUBLE_COLUMN_6,
      new.DOUBLE_COLUMN_7,
      new.DOUBLE_COLUMN_8,
      new.DOUBLE_COLUMN_9,
      new.DOUBLE_COLUMN_10,
      new.DATE_COLUMN_1,
      new.DATE_COLUMN_2,
      new.DATE_COLUMN_3,
      new.DATE_COLUMN_4,
      new.DATE_COLUMN_5,
      new.DATE_COLUMN_6,
      new.DATE_COLUMN_7,
      new.DATE_COLUMN_8,
      new.DATE_COLUMN_9,
      new.DATE_COLUMN_10,
      new.VARCHAR_COLUMN_1,
      new.VARCHAR_COLUMN_2,
      new.VARCHAR_COLUMN_3,
      new.VARCHAR_COLUMN_4,
      new.VARCHAR_COLUMN_5,
      new.VARCHAR_COLUMN_6,
      new.VARCHAR_COLUMN_7,
      new.VARCHAR_COLUMN_8,
      new.VARCHAR_COLUMN_9,
      new.VARCHAR_COLUMN_10,
      new.TEXT_COLUMN_1,
      new.TEXT_COLUMN_2,
      new.TEXT_COLUMN_3,
      new.BOOLEAN_COLUMN_1,
      new.BOOLEAN_COLUMN_2,
      new.BOOLEAN_COLUMN_3,
      new.BOOLEAN_COLUMN_4,
      new.BOOLEAN_COLUMN_5,
      new.HREF_COLUMN_1,
      new.HREF_COLUMN_2,
      new.HREF_COLUMN_3,
      new.HREF_COLUMN_4,
      new.HREF_COLUMN_5,
      new.HREF_COLUMN_1_NAME,
      new.HREF_COLUMN_2_NAME,
      new.HREF_COLUMN_3_NAME,
      new.HREF_COLUMN_4_NAME,
      new.HREF_COLUMN_5_NAME,
      new.STANDARD_COLUMN_1,
      new.STANDARD_COLUMN_2,
      new.STANDARD_COLUMN_3,
      new.STANDARD_COLUMN_4,
      new.STANDARD_COLUMN_5
    ) ;
  END IF ;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_fromat_itemfile_after_insert` AFTER INSERT ON `r_format_itemfile`
    FOR EACH ROW BEGIN
	DECLARE haveRecord TINYINT DEFAULT 0;
	/*DECLARE beCurrentEdition TINYINT DEFAULT 0; 是否当前版本，如果是历史版本，则不需要处理*/

	/*SELECT format_edition.is_current INTO beCurrentEdition FROM format_edition
		WHERE format_edition.uid = new.doc_edition_uid;*/

	/*只有当前版本才需要更新节次条目数量*/
	/*IF(beCurrentEdition) THEN*/

		SELECT 1 INTO haveRecord FROM format_item_statistics
			WHERE format_item_statistics.doc_edition_uid = new.doc_edition_uid
			AND format_item_statistics.item_uid = new.item_uid
			AND format_item_statistics.item_edition  = new.edition;

		IF haveRecord>0 THEN /*已经有记录*/
			UPDATE format_item_statistics
				SET format_item_statistics.attachment_sum = format_item_statistics.attachment_sum+1
			WHERE format_item_statistics.doc_edition_uid = new.doc_edition_uid
				AND format_item_statistics.item_uid = new.item_uid
				AND format_item_statistics.item_edition  = new.edition;
		ELSE  /*之前没有记录，插入新记录*/
			INSERT INTO format_item_statistics(format_item_statistics.doc_uid
				,format_item_statistics.doc_edition_uid
				,format_item_statistics.item_uid
				,format_item_statistics.item_edition
				,format_item_statistics.reference_sum
				,format_item_statistics.be_referenced_sum
				,format_item_statistics.attachment_sum)
				VALUES
				(new.doc_uid
				,new.doc_edition_uid
				,new.item_uid
				,new.edition
				,0
				,0
				,1);
		END IF;
	/*end if;*/
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_memorabilia_file_after_insert` AFTER INSERT ON `r_memorabilia_file`
    FOR EACH ROW BEGIN
	DECLARE userId INT;
	SELECT f.user_id INTO userId FROM `file` f WHERE f.id = new.file_id;
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
	VALUES (new.file_id,'16',NOW(),userId,'',0,2);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_question_file_after_insert` AFTER INSERT ON `r_question_file`
    FOR EACH ROW BEGIN
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
	VALUES (new.file_id,'21',NOW(),1,'',0,3);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_resource_file_after_insert` AFTER INSERT ON `r_resource_file`
    FOR EACH ROW BEGIN
	IF(new.fileuse_uid='6') THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'9',NOW(),new.creator_id,'',0);
	ELSE
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'6',NOW(),new.creator_id,'',0);
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_resource_file_after_update` AFTER UPDATE ON `r_resource_file`
    FOR EACH ROW BEGIN
	IF(new.fileuse_uid='6') THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'9',NOW(),new.creator_id,'',1);
	ELSE
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'6',NOW(),new.creator_id,'',1);
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_resource_tag_after_delete` AFTER DELETE ON `r_resource_tag`
    FOR EACH ROW BEGIN
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (old.resource_uid,'8',NOW(),0,old.tag,1);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_resource_tag_after_insert` AFTER INSERT ON `r_resource_tag`
    FOR EACH ROW BEGIN
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (new.resource_uid,'8',NOW(),0,new.tag,0);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_r_task_file_after_insert` AFTER INSERT ON `r_task_file`
    FOR EACH ROW BEGIN
	DECLARE milestone TINYINT;
	SELECT t.milestone INTO milestone FROM task t WHERE t.uid = new.taskUID;
	IF(milestone=1&&new.task_filetype='2') THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
		VALUES (new.file_id,'14',NOW(),new.user_id,'',0,1);
	END IF;

	IF(milestone=0) THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
		VALUES (new.file_id,'20',NOW(),new.user_id,'',0,3);
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_recurring_personal_report_update` AFTER UPDATE ON `recurring_personal_report`
    FOR EACH ROW BEGIN
    IF(new.is_deleted = 1) THEN
		DELETE FROM temp_task WHERE source_uid= old.uid;
    END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_resource_after_insert` AFTER INSERT ON `resource`
    FOR EACH ROW BEGIN
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (new.uid,'2',NOW(),new.creator_id,new.name,0);
	IF(new.comm IS NOT NULL) THEN
		IF(new.comm!='')THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
			VALUES (new.uid,'3',NOW(),new.creator_id,new.comm,0);
		END IF;
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_resource_after_update` AFTER UPDATE ON `resource`
    FOR EACH ROW BEGIN
	IF(new.is_deleted=1) THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (old.uid,'2',NOW(),old.creator_id,old.name,1);
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (old.uid,'3',NOW(),old.creator_id,old.comm,1);

	ELSE
		IF(new.name!=old.name) THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
			VALUES (old.uid,'2',NOW(),old.creator_id,old.name,1);
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
			VALUES (new.uid,'2',NOW(),new.creator_id,new.name,0);
		END IF;

		IF(new.comm!=old.comm) THEN
			IF(old.comm!='')THEN
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
				VALUES (old.uid,'3',NOW(),old.creator_id,old.comm,1);
			END IF;
			IF(new.comm!='')THEN
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
				VALUES (new.uid,'3',NOW(),new.creator_id,new.comm,0);
			END IF;
		END IF;
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_resource_edition_after_insert` AFTER INSERT ON `resource_edition`
    FOR EACH ROW BEGIN
	DECLARE resName VARCHAR(255);
	DECLARE userName VARCHAR(20) DEFAULT '';

	SELECT r.name
	INTO resName
	FROM resource AS r
	WHERE r.uid=new.resource_uid;

	SELECT p.name INTO userName FROM person p WHERE p.id=new.user_id;

	/**全文检索资源**/
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (new.uid,'4',NOW(),new.user_id,new.edition,0);
	IF(new.comm IS NOT NULL) THEN
		IF(new.comm!='')THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
			VALUES (new.uid,'5',NOW(),new.user_id,new.comm,0);
		END IF;
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_resource_edition_after_update` AFTER UPDATE ON `resource_edition`
    FOR EACH ROW BEGIN
	DECLARE STOP INT DEFAULT 0;
	DECLARE _userId INT;
	DECLARE messageId INT;
	DECLARE _userName VARCHAR(20);
	DECLARE mesTitle VARCHAR(500) DEFAULT '';
	DECLARE mesContent VARCHAR(16384) DEFAULT '';
	DECLARE mesUserId INT;
	DECLARE resName VARCHAR(255);
        DECLARE userName VARCHAR(20) DEFAULT '';

	DECLARE cursorName
	CURSOR FOR  (
		SELECT DISTINCT p.id,p.name
		FROM r_facet_feeds AS rff,person AS p,r_resource_facet AS rrf ,resource AS r
		WHERE  p.id=rff.user_id
		AND r.uid=new.resource_uid
		AND rff.facet_uid=rrf.facet_uid
		AND rrf.resource_uid=new.resource_uid
		AND (r.secret_uid='1' OR p.id IN (SELECT v.user_id FROM view_resource_auth_role AS v WHERE v.resource_uid=new.resource_uid))
	);

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET STOP=1;
	/**全文检索资源**/
	IF(new.is_deleted=1) THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (old.uid,'4',NOW(),old.user_id,old.edition,1);
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (old.uid,'5',NOW(),old.user_id,old.comm,1);

	/*修改可信等级不发布系统消息*/
	ELSEIF new.grade_uid=old.grade_uid THEN
		SELECT r.name INTO resName FROM resource AS r WHERE r.uid=new.resource_uid;

		SELECT p.name INTO userName FROM person p WHERE p.id=new.user_id;

		SET mesTitle =CONCAT('你订阅的资源',resName,'发生了变化：',userName,'更新了版本：',old.edition);
		SET mesContent=CONCAT('资源：<a href="openResourceInfo.action?resourceUid=',new.resource_uid,'" target="_blank" >',resName,'</a> 更新通知:<br>在<FONT color=#0000ff>',DATE_FORMAT(NOW(),'%Y-%m-%d'),'</font> 更新了版本<a href="openResourceEditionInfo.action?editionUid=',new.uid,'" target="_blank" >',new.edition,'</a>');
		OPEN cursorName;
		FETCH cursorName INTO _userId,_userName;
		WHILE STOP<>1 DO
		    IF(_userId!=new.user_id) THEN
			INSERT INTO
			message (recipient,content,title,sender_id,create_date,TYPE)
			VALUES (_userName,mesContent,mesTitle,new.user_id,NOW(),5);

			SELECT MAX(id) INTO messageId FROM message;
			INSERT INTO
			r_message_inbox(user_id,message_id,read_status)
			VALUES (_userId,messageId,1);
		    END IF;
		FETCH cursorName INTO _userId,_userName;
		END WHILE;
		CLOSE cursorName;

		IF(new.edition!=old.edition) THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
			VALUES (old.uid,'4',NOW(),old.user_id,old.edition,1);
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
			VALUES (new.uid,'4',NOW(),new.user_id,new.edition,0);
		END IF;

		IF(new.comm!=old.comm) THEN
			IF(old.comm!='')THEN
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
				VALUES (old.uid,'5',NOW(),old.user_id,old.comm,1);
			END IF;
			IF(new.comm!='')THEN
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
				VALUES (new.uid,'5',NOW(),new.user_id,new.comm,0);
			END IF;
		END IF;
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_resource_facet_after_delete` AFTER DELETE ON `resource_facet`
    FOR EACH ROW BEGIN
	INSERT INTO full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (old.uid,'7',NOW(),0,old.name,1);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_resource_facet_after_insert` AFTER INSERT ON `resource_facet`
    FOR EACH ROW BEGIN
	INSERT INTO
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (new.uid,'7',NOW(),0,new.name,0);
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_resource_facet_after_update` AFTER UPDATE ON `resource_facet`
    FOR EACH ROW BEGIN
	IF (new.name!=old.name OR new.comm!=old.comm) THEN
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.uid,'7',NOW(),0,new.name,0);
		INSERT INTO
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (old.uid,'7',NOW(),0,old.name,1);
	END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_s_currency_insert_after_insert` AFTER INSERT ON `s_currency`
    FOR EACH ROW BEGIN
	INSERT INTO r_currency_parities (currency_id,currency_parities) (SELECT sc.id,1 FROM s_currency sc WHERE sc.id NOT IN (SELECT rp.currency_id FROM r_currency_parities rp));
    END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_s_level_insert_after_insert` AFTER INSERT ON `s_level`
    FOR EACH ROW BEGIN
	INSERT INTO level_point(level_id,POINT)  (SELECT s_level.id,1 FROM s_level  WHERE s_level.id NOT IN (SELECT level_id FROM level_point));
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `tri_task_acceptance_after_insert` AFTER INSERT ON `task_acceptance`
    FOR EACH ROW BEGIN
DECLARE mesUserId INT;
    IF(new.user_id IS NULL) THEN
    SET mesUserId=1;
    ELSE
    SET mesUserId=new.user_id;
    END IF;
    IF(new.satisfaction IS NULL) THEN
    INSERT INTO task_log(taskUID,user_id,content,create_date,TYPE, is_dispose)
    VALUES(new.taskUID,mesUserId,CONCAT('任务未通过验收，驳回原因:',new.result_desc),NOW(), 2, 1);
    ELSE
    INSERT INTO task_log(taskUID,user_id,content,create_date,TYPE, is_dispose)
    VALUES(new.taskUID,mesUserId,CONCAT('任务通过验收，验收意见:',new.result_desc),NOW(), 2, 1);
    END IF;
    END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_task_acceptance_after_update` AFTER UPDATE ON `task_acceptance`
    FOR EACH ROW BEGIN
    DECLARE mesUserId INT;
    IF(new.user_id IS NULL) THEN
    SET mesUserId=1;
    ELSE
    SET mesUserId=new.user_id;
    END IF;
    IF(new.satisfaction IS NULL) THEN
    INSERT INTO task_log(taskUID,user_id,content,create_date,TYPE, is_dispose)
    VALUES(new.taskUID,mesUserId,CONCAT('任务未通过验收，驳回原因:',new.result_desc),NOW(), 2, 1);
    ELSE
    INSERT INTO task_log(taskUID,user_id,content,create_date,TYPE, is_dispose)
    VALUES(new.taskUID,mesUserId,CONCAT('任务通过验收，验收意见:',new.result_desc),NOW(), 2, 1);
    END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_task_after_insert` AFTER INSERT ON `task`
    FOR EACH ROW BEGIN
    DECLARE STOP INT DEFAULT 0;
	DECLARE _userId INT;
	DECLARE messageId INT;
	DECLARE temp VARCHAR(255) DEFAULT '';
	DECLARE tempName VARCHAR(255) DEFAULT '';
	DECLARE _userName VARCHAR(20);
        DECLARE mesTitle VARCHAR(500) DEFAULT '';
        DECLARE mesText VARCHAR(16384) DEFAULT '';
        DECLARE mesContent VARCHAR(16384) DEFAULT '';
        DECLARE mesUserId INT;
        DECLARE proName VARCHAR(127) DEFAULT '';
        DECLARE categoryName VARCHAR(127) DEFAULT '任务';
        DECLARE logContent VARCHAR(16384) DEFAULT '';
       	/*定义里程碑发送的人员*/
		DECLARE cursorName2 CURSOR FOR  (SELECT person.id,person.name FROM project,person  WHERE project.leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
					UNION
						(SELECT person.id,person.name FROM project,person WHERE project.quality_leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
					UNION
						(SELECT person.id,person.name FROM project,person WHERE project.officer_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
					UNION
						(SELECT p.id,p.name FROM project_person pro,person p WHERE pro.user_id =p.id AND pro.project_id=new.project_id AND p.is_deleted=FALSE);
       DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET STOP=1;

	       IF(new.milestone=1 || new.plan_category_id=2) THEN
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
			VALUES (new.uid,'12',NOW(),new.user_id,new.name,0,1);
			IF(new.notes IS NOT NULL) THEN
				IF(new.notes!='')THEN
					INSERT INTO
					full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
					VALUES (new.uid,'13',NOW(),new.user_id,new.notes,0,1);
				END IF;
			END IF;
			ELSE
			INSERT INTO
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
			VALUES (new.uid,'18',NOW(),new.user_id,new.name,0,3);
			IF(new.notes IS NOT NULL) THEN
				IF(new.notes!='')THEN
					INSERT INTO
					full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
					VALUES (new.uid,'19',NOW(),new.user_id,new.notes,0,3);
				END IF;
			END IF;

	       END IF;
	       IF(new.update_user_id)THEN
		   SET mesUserId=new.update_user_id;
	       END IF;
	       IF(!new.update_user_id)THEN
		   SET mesUserId=new.user_id;
	       END IF;
	       IF(new.parent_uid IS NOT NULL) THEN/*不为根任务*/
	           SELECT s.name INTO categoryName FROM s_task_plancategory s WHERE s.id = new.plan_category_id;
	           SET logContent =CONCAT("添加了 ",categoryName);
                   INSERT INTO
		        task_log(taskUID,user_id,content,create_date,TYPE)
		   VALUES(new.uid,mesUserId,logContent,NOW(),12);
               END IF;
               /*插入任务资源计划默认数据*/
               INSERT IGNORE INTO r_task_resource_level (SELECT new.uid,s.id,0,0,0,0 FROM s_level s);
		 /*查询重要程度*/
		  SELECT NAME INTO temp FROM s_task_important WHERE id = new.Important;
		 /*查询状态*/
		  SELECT NAME INTO tempName FROM s_task_status WHERE id = new.status;
		 /*查询项目名*/
		  SELECT NAME INTO proName FROM project WHERE id=new.project_id;
		/*如果是里程碑，则发布的内容是里程碑消息*/
		/*IF(new.Milestone=1) THEN */
		   /*设置发送邮件的标题*/
		/*     SET mesTitle =CONCAT('添加里程碑“',new.name,'”通知');*/
		/*    SET mesContent=CONCAT('<FONT color=#0000ff>',proName,'</FONT>中里程碑<FONT color=#0000ff>',new.name,'</FONT>发布通知:<br>发布时间：<FONT color=#0000ff>',DATE_FORMAT(new.Start,'%Y-%m-%d'),'</FONT><br>重要程度：<FONT color=#0000ff>',temp,'</FONT><br>状态：<FONT color=#0000ff>',tempName,'</FONT><br>交付成果：<FONT color=#0000ff>',new.deliverable_description,'</FONT><br>描述：<FONT color=#0000ff>',new.Notes,'</FONT>');*/
		/*     OPEN cursorName2;*/
		 /*      FETCH cursorName2 INTO _userId,_userName;*/
		 /*      WHILE STOP<>1 DO 	*/
		 /*      IF(_userId!=mesUserId) THEN   	*/
		 /*      INSERT INTO */
		 /*      message (recipient,content,title,sender_id,create_date,TYPE)*/
		  /*     VALUES (_userName,mesContent,mesTitle,mesUserId,NOW(),1);*/
		  /*     SELECT MAX(id) INTO messageId FROM message;*/
		 /*      INSERT INTO */
		  /*     r_message_inbox(user_id,message_id,read_status)*/
		  /*     VALUES (_userId,messageId,1);*/
		 /*      END IF;*/
		 /*      FETCH cursorName2 INTO _userId,_userName;*/
		 /*      END WHILE;*/
		  /*  CLOSE cursorName2;		 */
		/*END IF;*/
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_task_after_update` AFTER UPDATE ON `task`
    FOR EACH ROW BEGIN
		DECLARE STOP INT DEFAULT 0;
		DECLARE tempName VARCHAR(255) DEFAULT '';
		DECLARE temp VARCHAR(255) DEFAULT '';
		DECLARE _userId INT;
		DECLARE productName VARCHAR(255) DEFAULT '';
		DECLARE versionName VARCHAR(255) DEFAULT '';
		DECLARE moduleName VARCHAR(255) DEFAULT '';
		DECLARE flag INT DEFAULT 0;
		DECLARE messageId INT;
		DECLARE _userName VARCHAR(20);
	        DECLARE mesTitle VARCHAR(500) DEFAULT CONCAT('“',old.name,'”变化通知');
	        DECLARE mesText VARCHAR(16384) DEFAULT '';
	        DECLARE mesProduct VARCHAR(16384) DEFAULT '';
	        DECLARE mesContent VARCHAR(16384) DEFAULT '';
	        DECLARE mesUserId INT;
	        DECLARE proName VARCHAR(127) DEFAULT '';
	        DECLARE columnId INT;
	        DECLARE columnName VARCHAR(255) DEFAULT '';
	        DECLARE poName VARCHAR(255) DEFAULT '';
	        DECLARE enName VARCHAR(255) DEFAULT '';
	        DECLARE personName VARCHAR(255) DEFAULT '';
	        DECLARE unitName VARCHAR(255) DEFAULT '';
	        DECLARE standardName VARCHAR(255) DEFAULT '';
	        DECLARE dispose INT;
	        DECLARE categoryName  VARCHAR(255);
	        DECLARE projectStageName VARCHAR(255);
	       /*建立游标，查询出需要发送的人员信息*/
	        DECLARE cursorName CURSOR FOR  (SELECT person.id,person.name FROM project,person  WHERE project.leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
						UNION
							(SELECT person.id,person.name FROM project,person WHERE project.quality_leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
						UNION
							(SELECT person.id,person.name FROM project,person WHERE project.officer_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
						UNION
							(SELECT person.id,person.name FROM task_assignment,USER,person WHERE task_assignment.ResourceUID=USER.id AND USER.id=person.id AND task_assignment.TaskUID=new.uid AND person.is_deleted=FALSE);
	     /*定义里程碑发送的人员*/
		DECLARE cursorName2 CURSOR FOR  (SELECT person.id,person.name FROM project,person  WHERE project.leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
						UNION
							(SELECT person.id,person.name FROM project,person WHERE project.quality_leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
						UNION
							(SELECT person.id,person.name FROM project,person WHERE project.officer_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
						UNION
							(SELECT p.id,p.name FROM project_person pro,person p WHERE pro.user_id =p.id AND pro.project_id=new.project_id AND p.is_deleted=FALSE);
		/*查询工作任务自定义字段配置的游标*/
		DECLARE extend_column CURSOR FOR (SELECT  coulumn_id,column_name,pojo_name FROM page_entity_column WHERE entity_id=6);
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET STOP=1;
		      IF(old.Milestone=1 ||new.plan_category_id =2) THEN
			IF(new.name!=old.name) THEN
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
				VALUES (old.uid,'12',NOW(),old.user_id,old.name,1,1);
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
				VALUES (new.uid,'12',NOW(),new.user_id,new.name,0,1);
			END IF;
			IF(new.notes!=old.notes) THEN
				IF(old.notes!='')THEN
					INSERT INTO
					full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
					VALUES (old.uid,'13',NOW(),old.user_id,old.notes,1,1);
				END IF;
				IF(new.notes!='')THEN
					INSERT INTO
					full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
					VALUES (new.uid,'13',NOW(),new.user_id,new.notes,0,1);
				END IF;
			END IF;
			ELSE
			IF(new.name!=old.name) THEN
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
				VALUES (old.uid,'18',NOW(),old.user_id,old.name,1,3);
				INSERT INTO
				full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
				VALUES (new.uid,'18',NOW(),new.user_id,new.name,0,3);
			END IF;
			IF(new.notes!=old.notes) THEN
				IF(old.notes!='')THEN
					INSERT INTO
					full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
					VALUES (old.uid,'19',NOW(),old.user_id,old.notes,1,3);
				END IF;
				IF(new.notes!='')THEN
					INSERT INTO
					full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS,indexType)
					VALUES (new.uid,'19',NOW(),new.user_id,new.notes,0,3);
				END IF;
			END IF;
		      END IF;
		      IF(new.update_user_id IS NULL) THEN
			   SET mesUserId=1;
		       ELSE
			   SET mesUserId=new.update_user_id;
		       END IF;
		       /*查询项目名*/
			  SELECT NAME INTO proName FROM project WHERE id=new.project_id;
			/*设置发送信息的内容*/
			SET mesText=CONCAT('<FONT color=#0000ff>',proName,'</FONT>中的<a href="taskDetail.action?taskUID=',old.uid,'" target="_blank">',old.name,'</a>发生了变化：');/*此处添加了任务详细信息的超链接*/
			IF(old.Milestone=1) THEN/*此处添加了判断，如果是里程碑则不用超链接到任务的详细信息*/
				SET mesText=CONCAT('<FONT color=#0000ff>',proName,'</FONT>中的',old.name,'发生了变化：');
			 END IF;
			IF(old.name !=new.name) THEN
			SELECT s.name INTO categoryName FROM s_task_plancategory s WHERE s.id = new.plan_category_id;
			IF(new.parent_uid IS NOT NULL) THEN/*不为根任务*/

				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT(categoryName,'名称修改为:',new.name),NOW(),8);
			 END IF;

			 SET mesText=CONCAT(mesText,categoryName,'<br>名称修改为:<FONT color=#0000ff>',new.name,'</FONT>');

			END IF;
			IF(old.start!=new.start) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('开始时间修改为:',new.start),NOW(),1);
			END IF;
				IF(new.Milestone=0 && new.plan_category_id!=2) THEN
				  SET mesText=CONCAT(mesText,'<br>开始时间修改为:<FONT color=#0000ff>',new.start,'</FONT>');
				END IF;
				IF(new.Milestone=1 ||new.plan_category_id=2) THEN
				IF(new.start!='') THEN
				     SET mesText=CONCAT(mesText,'<br>开始时间修改为:<FONT color=#0000ff>',DATE_FORMAT(new.start,'%Y-%m-%d'),'</FONT>');
				END IF;
				END IF;
				SET flag  = 1;
			END IF;
			IF(old.actualStart!=new.actualStart) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('实际开始时间修改为:',new.actualStart),NOW(),1,1);
			END IF;
				SET mesText=CONCAT(mesText,'<br>实际开始时间修改为:<FONT color=#0000ff>',new.actualStart,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.finish!=new.finish) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('结束时间修改为:',new.finish),NOW(),1);
			END IF;
				IF(new.Milestone=0) THEN
				SET mesText=CONCAT(mesText,'<br>结束时间修改为:<FONT color=#0000ff>',new.finish,'</FONT>');
				END IF;
				SET flag  = 1;
			END IF;
			IF(old.ActualFinish!=new.ActualFinish) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('实际结束时间修改为:',new.ActualFinish),NOW(),1,1);
			END IF;
				 IF(new.Milestone=0) THEN
				  SET mesText=CONCAT(mesText,'<br>实际结束时间修改为:<FONT color=#0000ff>',new.ActualFinish,'</FONT>');
				END IF;
				IF(new.Milestone=1) THEN
				IF(new.ActualFinish!='') THEN
				     SET mesText=CONCAT(mesText,'<br>结束时间修改为:<FONT color=#0000ff>',DATE_FORMAT(new.ActualFinish,'%Y-%m-%d'),'</FONT>');
				END IF;
				END IF;
				SET flag  = 1;
			END IF;
			IF(old.percentcomplete!=new.percentcomplete) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('完成比例从：',old.percentcomplete,'% 修改为:',new.percentcomplete,'%'),NOW(),6,1);
		       END IF;
				SET mesText=CONCAT(mesText,'<br>完成比例从：<FONT color=#0000ff>',old.percentcomplete,'%</FONT>修改为:<FONT color=#0000ff>',new.percentcomplete,'%</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.duration!=new.duration) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('工期修改为:',new.duration),NOW(),7);
			END IF;
				SET mesText=CONCAT(mesText,'<br>工期修改为:<FONT color=#0000ff>',new.duration,'</FONT>');
				SET flag  = 1;
			END IF;
				IF(old.status!=new.status) THEN
				SELECT NAME INTO tempName FROM s_task_status WHERE id = new.status;
				IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('任务状态修改为:',tempName),NOW(),2,1);
				END IF;
				SET mesText=CONCAT(mesText,'<br>状态修改为:<FONT color=#0000ff>',tempName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.category!=new.category) THEN
				SELECT NAME INTO tempName FROM s_task_category WHERE id = new.category;
				IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('任务类型修改为:',tempName),NOW(),13);
				END IF;
				SET mesText=CONCAT(mesText,'<br>类型修改为:<FONT color=#0000ff>',tempName,'</FONT>');
				SET flag  = 1;
			END IF;
				IF(old.relevanceMilestone!=new.relevanceMilestone) THEN
				SELECT NAME INTO tempName FROM task WHERE uid = new.relevanceMilestone;
				IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('任务所属节点计划修改为:',tempName),NOW(),14);
				END IF;
				SET mesText=CONCAT(mesText,'<br>所属节点计划修改为:<FONT color=#0000ff>',tempName,'</FONT>');
				SET flag  = 1;
			END IF;
				IF(old.is_default!=new.is_default && new.is_default) THEN
				IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('任务所属节点的关联状态设置为:','默认'),NOW(),15);
				END IF;
				SET mesText=CONCAT(mesText,'<br>所属节点的关联状态设置为:<FONT color=#0000ff>','默认','</FONT>');
				SET flag  = 1;
			END IF;
				IF(old.product_uid != new.product_uid || old.product_version_uid != new.product_version_uid || old.module_uid != new.module_uid) THEN
				SELECT NAME INTO productName FROM product WHERE product_uid = new.product_uid;
				SELECT VERSION INTO versionName FROM product_version WHERE product_uid = new.product_uid AND product_version_uid = new.product_version_uid;
				SELECT NAME INTO moduleName  FROM product_version_module WHERE product_uid = new.product_uid AND product_version_uid = new.product_version_uid AND module_uid = new.module_uid;
				IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
					IF(productName IS NOT NULL) THEN
						SET mesProduct=CONCAT(mesProduct,'任务关联产品修改，产品：',productName);
						SET mesText=CONCAT(mesText,'<br>关联产品修改为，产品：<FONT color=#0000ff>',productName,'</FONT>');
						ELSE
						SET mesProduct=CONCAT('取消了任务与产品的关联');
						SET mesText=CONCAT(mesText,'<br>取消了任务与产品的关联');
					END IF;
					IF(versionName IS NOT NULL) THEN
						SET mesProduct=CONCAT(mesProduct,'，版本：',versionName);
						SET mesText=CONCAT(mesText,'&nbsp;&nbsp;版本：<FONT color=#0000ff>',versionName,'</FONT>');
					END IF;
					IF(moduleName IS NOT NULL) THEN
						SET mesProduct=CONCAT(mesProduct,'，模块：',moduleName);
						SET mesText=CONCAT(mesText,'&nbsp;&nbsp;模块：<FONT color=#0000ff>',moduleName,'</FONT>');
					END IF;
					INSERT INTO
						task_log(taskUID,user_id,content,create_date,TYPE)
						VALUES(old.uid,mesUserId,mesProduct,NOW(),16);
				END IF;
				SET flag  = 1;
			END IF;
			IF(old.Important!=new.Important) THEN
				SELECT NAME INTO tempName FROM s_task_important WHERE id = new.Important;
				IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('任务重要度修改为:',tempName),NOW(),10);
	                         END IF;
				SET mesText=CONCAT(mesText,'<br>重要度修改为:<FONT color=#0000ff>',tempName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.notes!=new.notes) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('任务描述修改为:',new.notes),NOW(),7);
			END IF;
				SET mesText=CONCAT(mesText,'<br>任务描述修改为:<FONT color=#0000ff>',new.notes,'</FONT>');
				SET flag  = 1;
			END IF;
			/*计划工时修改*/
			IF(old.working_hours!=new.working_hours) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('任务计划工时修改为:',new.working_hours),NOW(),7);
			END IF;
				SET mesText=CONCAT(mesText,'<br>任务计划工时修改为:<FONT color=#0000ff>',new.working_hours,'</FONT>');
				SET flag  = 1;
			END IF;
			/*已用工时修改*/
			IF(old.actual_working_hours!=new.actual_working_hours) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('任务已用工时修改为:',new.actual_working_hours),NOW(),7);
			END IF;
				SET mesText=CONCAT(mesText,'<br>任务已用工时修改为:<FONT color=#0000ff>',new.actual_working_hours,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& INT类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.int_column_1 IS NULL && new.int_column_1 IS NOT NULL)||(old.int_column_1 IS NOT NULL && new.int_column_1 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name, page_entity_column.is_dispose INTO columnName  ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_1),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_1,'</FONT>');
				SET flag  = 1;
			END IF;
    	                IF(old.int_column_1!=new.int_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name, page_entity_column.is_dispose  INTO columnName ,dispose  FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_1),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_1,'</FONT>');
				SET flag  = 1;
			END IF;


			IF((old.int_column_2 IS NULL && new.int_column_2 IS NOT NULL)||(old.int_column_2 IS NOT NULL && new.int_column_2 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose  INTO columnName ,dispose  FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_2),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_2,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_2!=new.int_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       SELECT  page_entity_column.column_name , page_entity_column.is_dispose  INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_2),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_2,'</FONT>');
				SET flag  = 1;
			END IF;


			IF((old.int_column_3 IS NULL && new.int_column_3 IS NOT NULL)||(old.int_column_3 IS NOT NULL && new.int_column_3 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose  INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_3),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_3,'</FONT>');
				SET flag  = 1;
			END IF;

			IF(old.int_column_3!=new.int_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose  INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND
			       	page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_3),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_3,'</FONT>');
				SET flag  = 1;
			END IF;


			IF((old.int_column_4 IS NULL && new.int_column_4 IS NOT NULL)||(old.int_column_4 IS NOT NULL && new.int_column_4 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_4),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_4,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_4!=new.int_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_4),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_4,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.int_column_5 IS NULL && new.int_column_5 IS NOT NULL)||(old.int_column_5 IS NOT NULL && new.int_column_5 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_5),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_5,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_5!=new.int_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_5),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_5,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.int_column_6 IS NULL && new.int_column_6 IS NOT NULL)||(old.int_column_6 IS NOT NULL && new.int_column_6 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_6';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_6),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_6,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_6!=new.int_column_6) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_6';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_6),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_6,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.int_column_7 IS NULL && new.int_column_7 IS NOT NULL)||(old.int_column_7 IS NOT NULL && new.int_column_7 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_7';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_7),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_7,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_7!=new.int_column_7) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_7';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_7),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_7,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.int_column_7 IS NULL && new.int_column_8 IS NOT NULL)||(old.int_column_8 IS NOT NULL && new.int_column_8 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_8';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_8),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_8,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_8!=new.int_column_8) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_8';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_8),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_8,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.int_column_9 IS NULL && new.int_column_9 IS NOT NULL)||(old.int_column_9 IS NOT NULL && new.int_column_9 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_9';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_9),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_9,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_9!=new.int_column_9) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_9';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_9),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_9,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.int_column_10 IS NULL && new.int_column_10 IS NOT NULL)||(old.int_column_10 IS NOT NULL && new.int_column_10 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_10';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_10),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_10,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.int_column_10!=new.int_column_10) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='int_column_10';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.int_column_10),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.int_column_10,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& INT类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DOUBLE类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.double_column_1 IS NULL && new.double_column_1 IS NOT NULL)||(old.double_column_1 IS NOT NULL && new.double_column_1 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_1),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_1,'</FONT>');
				SET flag  = 1;
			END IF;
    	                IF(old.double_column_1!=new.double_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_1),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_1,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_2 IS NULL && new.double_column_2 IS NOT NULL)||(old.double_column_2 IS NOT NULL && new.double_column_2 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_2),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_2,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_2!=new.double_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_2),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_2,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_3 IS NULL && new.double_column_3 IS NOT NULL)||(old.double_column_3 IS NOT NULL && new.double_column_3 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_3),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_3,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_3!=new.double_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_3),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_3,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_4 IS NULL && new.double_column_4 IS NOT NULL)||(old.double_column_4 IS NOT NULL && new.double_column_4 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_4),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_4,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_4!=new.double_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_4),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_4,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_5 IS NULL && new.double_column_5 IS NOT NULL)||(old.double_column_5 IS NOT NULL && new.double_column_5 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_5),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_5,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_5!=new.double_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_5),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_5,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_6 IS NULL && new.double_column_6 IS NOT NULL)||(old.double_column_6 IS NOT NULL && new.double_column_6 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_6';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_6),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_6,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_6!=new.double_column_6) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_6';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_6),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_6,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_7 IS NULL && new.double_column_7 IS NOT NULL)||(old.double_column_7 IS NOT NULL && new.double_column_7 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_7';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_7),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_7,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_7!=new.double_column_7) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_7';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_7),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_7,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_8 IS NULL && new.double_column_8 IS NOT NULL)||(old.double_column_8 IS NOT NULL && new.double_column_8 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_8';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_8),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_8,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_8!=new.double_column_8) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_8';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_8),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_8,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_9 IS NULL && new.double_column_9 IS NOT NULL)||(old.double_column_9 IS NOT NULL && new.double_column_9 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_9';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_9),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_9,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_9!=new.double_column_9) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_9';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_9),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_9,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.double_column_10 IS NULL && new.double_column_10 IS NOT NULL)||(old.double_column_10 IS NOT NULL && new.double_column_10 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_10';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_10),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_10,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.double_column_10!=new.double_column_10) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='double_column_10';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.double_column_10),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.double_column_10,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DOUBLE类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DATE类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.date_column_1 IS NULL && new.date_column_1 IS NOT NULL)||(old.date_column_1 IS NOT NULL && new.date_column_1 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_1),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_1,'</FONT>');
				SET flag  = 1;
			END IF;
    	                IF(old.date_column_1!=new.date_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_1),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_1,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_2 IS NULL && new.date_column_2 IS NOT NULL)||(old.date_column_2 IS NOT NULL && new.date_column_2 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_2),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_2,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_2!=new.date_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_2),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_2,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_3 IS NULL && new.date_column_3 IS NOT NULL)||(old.date_column_3 IS NOT NULL && new.date_column_3 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_3),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_3,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_3!=new.date_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_3),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_3,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_4 IS NULL && new.date_column_4 IS NOT NULL)||(old.date_column_4 IS NOT NULL && new.date_column_4 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_4),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_4,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_4!=new.date_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_4),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_4,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_5 IS NULL && new.date_column_5 IS NOT NULL)||(old.date_column_5 IS NOT NULL && new.date_column_5 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_5),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_5,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_5!=new.date_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_5),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_5,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_6 IS NULL && new.date_column_6 IS NOT NULL)||(old.date_column_6 IS NOT NULL && new.date_column_6 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_6';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_6),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_6,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_6!=new.date_column_6) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_6';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_6),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_6,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_7 IS NULL && new.date_column_7 IS NOT NULL)||(old.date_column_7 IS NOT NULL && new.date_column_7 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_7';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_7),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_7,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_7!=new.date_column_7) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_7';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_7),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_7,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_8 IS NULL && new.date_column_8 IS NOT NULL)||(old.date_column_8 IS NOT NULL && new.date_column_8 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_8';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_8),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_8,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_8!=new.date_column_8) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_8';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_8),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_8,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_9 IS NULL && new.date_column_9 IS NOT NULL)||(old.date_column_9 IS NOT NULL && new.date_column_9 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_9';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_9),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_9,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_9!=new.date_column_9) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_9';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_9),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_9,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.date_column_10 IS NULL && new.date_column_10 IS NOT NULL)||(old.date_column_10 IS NOT NULL && new.date_column_10 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_10';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_10),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_10,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.date_column_10!=new.date_column_10) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='date_column_10';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.date_column_10),NOW(),1,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.date_column_10,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Date类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& VARCHAR类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF(old.varchar_column_1!=new.varchar_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_1),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_1,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_2!=new.varchar_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_2),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_2,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_3!=new.varchar_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_3),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_3,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_4!=new.varchar_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_4),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_4,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_5!=new.varchar_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_5),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_5,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_6!=new.varchar_column_6) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_6';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_6),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_6,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_7!=new.varchar_column_7) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_7';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_7),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_7,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_8!=new.varchar_column_8) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_8';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_8),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_8,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_9!=new.varchar_column_9) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_9';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_9),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_9,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.varchar_column_10!=new.varchar_column_10) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='varchar_column_10';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',new.varchar_column_10),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',new.varchar_column_10,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& VARCHAR类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& BOOLEAN类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.boolean_column_1 IS NULL && new.boolean_column_1 IS NOT NULL)||(old.boolean_column_1 IS NOT NULL && new.boolean_column_1 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_1,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_1,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
    	                IF(old.boolean_column_1!=new.boolean_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_1,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_1,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.boolean_column_2 IS NULL && new.boolean_column_2 IS NOT NULL)||(old.boolean_column_2 IS NOT NULL && new.boolean_column_2 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_2,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_2,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.boolean_column_2!=new.boolean_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_2,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_2,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.boolean_column_3 IS NULL && new.boolean_column_3 IS NOT NULL)||(old.boolean_column_3 IS NOT NULL && new.boolean_column_3 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_3,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_3,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.boolean_column_3!=new.boolean_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_3,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_3,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.boolean_column_4 IS NULL && new.boolean_column_4 IS NOT NULL)||(old.boolean_column_4 IS NOT NULL && new.boolean_column_4 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_4,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_4,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.boolean_column_4!=new.boolean_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_4,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_4,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.boolean_column_5 IS NULL && new.boolean_column_5 IS NOT NULL)||(old.boolean_column_5 IS NOT NULL && new.boolean_column_5 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_5,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_5,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.boolean_column_5!=new.boolean_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='boolean_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',IF(new.boolean_column_5,'是','否')),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',IF(new.boolean_column_5,'是','否'),'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& BOOLEAN类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& URL类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF(old.href_column_1!=new.href_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='href_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:<a href="',new.href_column_1,'" target="_blank">',new.href_column_1_name,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<a href="',new.href_column_1,'" target="_blank">',new.href_column_1_name,'</a>','</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.href_column_2!=new.href_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='href_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:<a href="',new.href_column_2,'" target="_blank">',new.href_column_2_name,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<a href="',new.href_column_2,'" target="_blank">',new.href_column_2_name,'</a>','</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.href_column_3!=new.href_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='href_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:<a href="',new.href_column_3,'" target="_blank">',new.href_column_3_name,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<a href="',new.href_column_3,'" target="_blank">',new.href_column_3_name,'</a>','</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.href_column_4!=new.href_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='href_column_4';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:<a href="',new.href_column_4,'" target="_blank">',new.href_column_4_name,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<a href="',new.href_column_4,'" target="_blank">',new.href_column_4_name,'</a>','</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.href_column_5!=new.href_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='href_column_5';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:<a href="',new.href_column_5,'" target="_blank">',new.href_column_5_name,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<a href="',new.href_column_5,'" target="_blank">',new.href_column_5_name,'</a>','</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& URL类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& WEB类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.text_column_1 IS NULL && new.text_column_1 IS NOT NULL)||(old.text_column_1 IS NOT NULL && new.text_column_1 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='text_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn1&entityId=2" target="_blank">',columnName,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>','修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn1&entityId=2" target="_blank">',columnName,'</a>');
				SET flag  = 1;
			END IF;
    	                IF(old.text_column_1!=new.text_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='text_column_1';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn1&entityId=2" target="_blank">',columnName,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>','修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn1&entityId=2" target="_blank">',columnName,'</a>');
				SET flag  = 1;
			END IF;
			IF((old.text_column_2 IS NULL && new.text_column_2 IS NOT NULL)||(old.text_column_2 IS NOT NULL && new.text_column_2 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='text_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn2&entityId=2" target="_blank">',columnName,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>','修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn2&entityId=2" target="_blank">',columnName,'</a>');
				SET flag  = 1;
			END IF;
			IF(old.text_column_2!=new.text_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='text_column_2';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn2&entityId=2" target="_blank">',columnName,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>','修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn2&entityId=2" target="_blank">',columnName,'</a>');
				SET flag  = 1;
			END IF;
			IF((old.text_column_3 IS NULL && new.text_column_3 IS NOT NULL)||(old.text_column_3 IS NOT NULL && new.text_column_3 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='text_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn3&entityId=2" target="_blank">',columnName,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>','修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn3&entityId=2" target="_blank">',columnName,'</a>');
				SET flag  = 1;
			END IF;
			IF(old.text_column_3!=new.text_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='text_column_3';
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT('修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn3&entityId=2" target="_blank">',columnName,'</a>'),NOW(),7,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>','修改了:<a href="lookLogInfo.action?taskUid=',old.uid,'&name=',columnName,'&columnName=TextColumn3&entityId=2" target="_blank">',columnName,'</a>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& WEB类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& PERSON类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.person_column_1 IS NULL && new.person_column_1 IS NOT NULL)||(old.person_column_1 IS NOT NULL && new.person_column_1 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_1';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_1;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
    	                IF(old.person_column_1!=new.person_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_1';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_1;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.person_column_2 IS NULL && new.person_column_2 IS NOT NULL)||(old.person_column_2 IS NOT NULL && new.person_column_2 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_2';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_2;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.person_column_2!=new.person_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_2';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_2;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.person_column_3 IS NULL && new.person_column_3 IS NOT NULL)||(old.person_column_3 IS NOT NULL && new.person_column_3 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_3';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_3;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.person_column_3!=new.person_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_3';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_3;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.person_column_4 IS NULL && new.person_column_4 IS NOT NULL)||(old.person_column_4 IS NOT NULL && new.person_column_4 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_4';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_4;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.person_column_4!=new.person_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_4';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_4;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.person_column_5 IS NULL && new.person_column_5 IS NOT NULL)||(old.person_column_5 IS NOT NULL && new.person_column_5 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_5';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_5;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.person_column_5!=new.person_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='person_column_5';
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_column_5;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',personName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',personName,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& PERSON类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Unit类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.unit_column_1 IS NULL && new.unit_column_1 IS NOT NULL)||(old.unit_column_1 IS NOT NULL && new.unit_column_1 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_1';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_1;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
    	                IF(old.unit_column_1!=new.unit_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_1';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_1;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.unit_column_2 IS NULL && new.unit_column_2 IS NOT NULL)||(old.unit_column_2 IS NOT NULL && new.unit_column_2 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_2';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_2;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.unit_column_2!=new.unit_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_2';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_2;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.unit_column_3 IS NULL && new.unit_column_3 IS NOT NULL)||(old.unit_column_3 IS NOT NULL && new.unit_column_3 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_3';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_3;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.unit_column_3!=new.unit_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_3';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_3;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.unit_column_4 IS NULL && new.unit_column_4 IS NOT NULL)||(old.unit_column_4 IS NOT NULL && new.unit_column_4 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_4';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_4;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.unit_column_4!=new.unit_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_4';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_4;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF((old.unit_column_5 IS NULL && new.unit_column_5 IS NOT NULL)||(old.unit_column_5 IS NOT NULL && new.unit_column_5 IS NULL)) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_5';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_5;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.unit_column_5!=new.unit_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='unit_column_5';
				SELECT  NAME INTO unitName FROM  unit WHERE id=new.unit_column_5;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',unitName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',unitName,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& unit类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 系统标准类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF(old.standard_column_1!=new.standard_column_1) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='standard_column_1';
				SELECT  NAME INTO standardName FROM  s_task_standard_table1 WHERE id=new.standard_column_1;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',standardName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',standardName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.standard_column_2!=new.standard_column_2) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='standard_column_2';
				SELECT  NAME INTO standardName FROM  s_task_standard_table2 WHERE id=new.standard_column_2;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',standardName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',standardName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.standard_column_3!=new.standard_column_3) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='standard_column_3';
				SELECT  NAME INTO standardName FROM  s_task_standard_table3 WHERE id=new.standard_column_3;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',standardName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',standardName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.standard_column_4!=new.standard_column_4) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='standard_column_4';
				SELECT  NAME INTO standardName FROM  s_task_standard_table4 WHERE id=new.standard_column_4;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',standardName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',standardName,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.standard_column_5!=new.standard_column_5) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
			       	SELECT  page_entity_column.column_name , page_entity_column.is_dispose INTO columnName ,dispose FROM page_entity_column ,page_defined_column WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=6 AND page_defined_column.column_name='standard_column_5';
				SELECT  NAME INTO standardName FROM  s_task_standard_table5 WHERE id=new.standard_column_5;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE,is_dispose)
				VALUES(old.uid,mesUserId,CONCAT(columnName,'修改为:',standardName),NOW(),5,dispose);
			END IF;
				SET mesText=CONCAT(mesText,'<br>',columnName,'修改为:<FONT color=#0000ff>',standardName,'</FONT>');
				SET flag  = 1;
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 系统标准类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF(old.deliverable_description!=new.deliverable_description) THEN
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('交付成果修改为:',new.deliverable_description),NOW(),4);
			END IF;
				SET mesText=CONCAT(mesText,'<br>交付成果修改为:<FONT color=#0000ff>',new.deliverable_description,'</FONT>');
				SET flag  = 1;
			END IF;
			IF(old.stage_id!=new.stage_id) THEN
			IF(new.parent_uid IS NOT NULL ) THEN/*不为根任务*/
			        SELECT  s.name INTO projectStageName FROM s_project_stage s WHERE s.id = new.stage_id;
				INSERT INTO
				task_log(taskUID,user_id,content,create_date,TYPE)
				VALUES(old.uid,mesUserId,CONCAT('阶段类型修改为:',projectStageName),NOW(),4);
			END IF;
				SET mesText=CONCAT(mesText,'<br>阶段类型修改为:<FONT color=#0000ff>',projectStageName,'</FONT>');
				SET flag  = 1;
			END IF;
		END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_task_before_update` BEFORE UPDATE ON `task`
    FOR EACH ROW BEGIN
	DECLARE plan_all_duration INT DEFAULT 0;/*计划总工作日*/
	IF old.status!=new.status && new.status =2 THEN
		/*update任务工期*/
		SET new.used_task_duration = 0;
		IF (SELECT HOUR(new.finish)) = 23 && (SELECT MINUTE(old.finish)) = 59 && (SELECT SECOND(old.finish)) =59 THEN
			SET plan_all_duration = (SELECT calc_current_time_work(old.start,(SELECT DATEDIFF(old.finish,old.start))+1));
		ELSE
			SET plan_all_duration = (SELECT calc_current_time_work(old.start,(SELECT DATEDIFF(old.finish,old.start))));
		END IF;
		SET new.remain_task_duration = plan_all_duration;
		SET new.plan_all_duration = plan_all_duration;
		SET new.used_point = 0;
		SET new.remain_point = 100;
        END IF;
END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_ticket_after_update` AFTER UPDATE ON `ticket`
    FOR EACH ROW BEGIN
		DECLARE STOP INT DEFAULT 0;
		DECLARE oldTempName VARCHAR(255) DEFAULT NULL;
		DECLARE tempName VARCHAR(255) DEFAULT NULL;
		DECLARE productName VARCHAR(255) DEFAULT NULL;
		DECLARE versionName VARCHAR(255) DEFAULT NULL;
		DECLARE moduleName VARCHAR(255) DEFAULT NULL;
		DECLARE productNameOld VARCHAR(255) DEFAULT NULL;
		DECLARE versionNameOld VARCHAR(255) DEFAULT NULL;
		DECLARE moduleNameOld VARCHAR(255) DEFAULT NULL;
	    DECLARE mesText VARCHAR(16384) DEFAULT '';
	    DECLARE columnName VARCHAR(255) DEFAULT '';
        DECLARE personName VARCHAR(255) DEFAULT NULL;
        DECLARE personNameOld VARCHAR(255) DEFAULT NULL;
        DECLARE taskUid VARCHAR(32) DEFAULT '';
        DECLARE statusName VARCHAR(64) DEFAULT '';
		DECLARE statusNameOld VARCHAR(64) DEFAULT '';
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET STOP=1;
			/*设置发送信息的内容*/
			SET mesText=' ';
			IF(old.status_id = new.status_id && (!old.modify_reportwork ^ new.modify_reportwork)) THEN
			IF((old.title IS NOT NULL &&  new.title IS NOT NULL && old.title!=new.title)
				|| ((old.title IS NULL) ^ (new.title IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='title';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.title, '空'), ' 到 ', IFNULL(new.title, '空'),'<br/>');
			END IF;
			IF((old.environment_desc IS NOT NULL && new.environment_desc IS NOT NULL && old.environment_desc!=new.environment_desc)
				|| ((old.environment_desc IS NULL) ^ (new.environment_desc IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='environment_desc';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.environment_desc, '空'), ' 到 ', IFNULL(new.environment_desc, '空'),'<br/>');
			END IF;
			IF((old.born_address IS NOT NULL && new.born_address IS NOT NULL && old.born_address!=new.born_address)
				|| ((old.born_address IS NULL) ^ (new.born_address IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='born_address';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.born_address, '空'), ' 到 ', IFNULL(new.born_address, '空'),'<br/>');
			END IF;
			IF((old.born_time IS NOT NULL && new.born_time IS NOT NULL && old.born_time!=new.born_time)
				|| ((old.born_time IS NULL) ^ (new.born_time IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='born_time';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.born_time, '空'), ' 到 ', IFNULL(new.born_time, '空'),'<br/>');
			END IF;
			IF((old.milestone_id IS NOT NULL && new.milestone_id IS NOT NULL && old.milestone_id!=new.milestone_id)
				|| ((old.milestone_id IS NULL) ^ (new.milestone_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='milestone_id';
				SELECT NAME INTO oldTempName FROM milestone WHERE uid=old.milestone_id;
				SELECT NAME INTO tempName FROM milestone WHERE uid=new.milestone_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.finder IS NOT NULL && new.finder IS NOT NULL && old.finder!=new.finder)
				|| ((old.finder IS NULL) ^ (new.finder IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='finder';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.finder, '空'), ' 到 ', IFNULL(new.finder, '空'),'<br/>');
			END IF;
			IF((old.plan_resolved_product_version_uid IS NOT NULL && new.plan_resolved_product_version_uid IS NOT NULL && old.plan_resolved_product_version_uid!=new.plan_resolved_product_version_uid)
				|| ((old.plan_resolved_product_version_uid IS NULL) ^ (new.plan_resolved_product_version_uid IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='plan_resolved_product_version_uid';
				SELECT VERSION INTO tempName FROM product_version WHERE product_uid = new.product_uid AND product_version_uid = new.plan_resolved_product_version_uid;
				SELECT VERSION INTO oldTempName FROM product_version WHERE product_uid = old.product_uid AND product_version_uid = old.plan_resolved_product_version_uid;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF(((old.product_uid IS NOT NULL &&  new.product_uid IS NOT NULL && old.product_uid!=new.product_uid)
				|| ((old.product_uid IS NULL) ^ (new.product_uid IS NULL)))
				|| ((old.product_version_uid IS NOT NULL && new.product_version_uid IS NOT NULL && old.product_version_uid!=new.product_version_uid)
				|| ((old.product_version_uid IS NULL) ^ (new.product_version_uid IS NULL)))
				|| ((old.module_uid IS NOT NULL && new.module_uid IS NOT NULL && old.module_uid!=new.module_uid)
				|| ((old.module_uid IS NULL) ^ (new.module_uid IS NULL)))) THEN
				SET productNameOld='';
				SET productName='';
				SET versionNameOld='';
				SET versionName='';
				SET moduleNameOld='';
				SET moduleName='';
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='product_info';
				SELECT NAME INTO productName FROM product WHERE product_uid = new.product_uid;
				SELECT NAME INTO productNameOld FROM product WHERE product_uid = old.product_uid;
				IF(((old.product_version_uid IS NOT NULL &&  new.product_version_uid IS NOT NULL && old.product_version_uid!=new.product_version_uid)
					|| ((old.product_version_uid IS NULL) ^ (new.product_version_uid IS NULL)))
					|| ((old.module_uid IS NOT NULL && new.module_uid IS NOT NULL && old.module_uid!=new.module_uid)
					|| ((old.module_uid IS NULL) ^ (new.module_uid IS NULL)))) THEN
					SELECT VERSION INTO versionName FROM product_version WHERE product_uid = new.product_uid AND product_version_uid = new.product_version_uid;
					SELECT VERSION INTO versionNameOld FROM product_version WHERE product_uid = old.product_uid AND product_version_uid = old.product_version_uid;
					IF((old.module_uid IS NOT NULL && new.module_uid IS NOT NULL && old.module_uid!=new.module_uid)
						|| ((old.module_uid IS NULL) ^ (new.module_uid IS NULL))) THEN
						SELECT NAME INTO moduleName  FROM product_version_module WHERE product_uid = new.product_uid AND product_version_uid = new.product_version_uid AND module_uid = new.module_uid;
						SELECT NAME INTO moduleNameOld  FROM product_version_module WHERE product_uid = old.product_uid AND product_version_uid = old.product_version_uid AND module_uid = old.module_uid;
					END IF;
				END IF;
				IF(productNameOld IS NOT NULL && productNameOld!='') THEN
					SET oldTempName=productNameOld;
					IF(versionNameOld IS NOT NULL && versionNameOld!='') THEN
						SET oldTempName=CONCAT(oldTempName, ",", versionNameOld);
						IF(moduleNameOld IS NOT NULL && moduleNameOld!='') THEN
							SET oldTempName=CONCAT(oldTempName, ",", moduleNameOld);
						END IF;
					END IF;
				END IF;
				IF(productName IS NOT NULL && productName!='') THEN
					SET tempName=productName;
					IF(versionName IS NOT NULL && versionName!='') THEN
						SET tempName=CONCAT(tempName, ",", versionName);
						IF(moduleName IS NOT NULL && moduleName!='') THEN
							SET tempName=CONCAT(tempName, ",", moduleName);
						END IF;
					END IF;
				END IF;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.priority_id IS NOT NULL && new.priority_id IS NOT NULL && old.priority_id!=new.priority_id)
				|| ((old.priority_id IS NULL) ^ (new.priority_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='priority_id';
				SELECT NAME INTO oldTempName FROM s_ticket_priority WHERE id=old.priority_id;
				SELECT NAME INTO tempName FROM s_ticket_priority WHERE id=new.priority_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.severity_id IS NOT NULL && new.severity_id IS NOT NULL && old.severity_id!=new.severity_id)
				|| ((old.severity_id IS NULL) ^ (new.severity_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='severity_id';
				SELECT NAME INTO oldTempName FROM s_ticket_severity WHERE id=old.severity_id;
				SELECT NAME INTO tempName FROM s_ticket_severity WHERE id=new.severity_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.source_id IS NOT NULL && new.source_id IS NOT NULL && old.source_id!=new.source_id)
				|| ((old.source_id IS NULL) ^ (new.source_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='source_id';
				SELECT NAME INTO oldTempName FROM s_ticket_source WHERE id=old.source_id;
				SELECT NAME INTO tempName FROM s_ticket_source WHERE id=new.source_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.type_id IS NOT NULL && new.type_id IS NOT NULL && old.type_id!=new.type_id)
				|| ((old.type_id IS NULL) ^ (new.type_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='type_id';
				SELECT NAME INTO oldTempName FROM s_ticket_type WHERE id=old.type_id;
				SELECT NAME INTO tempName FROM s_ticket_type WHERE id=new.type_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.resolution_id IS NOT NULL && new.resolution_id IS NOT NULL && old.resolution_id!=new.resolution_id)
				|| ((old.resolution_id IS NULL) ^ (new.resolution_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='resolution_id';
				SELECT NAME INTO oldTempName FROM s_ticket_resolution WHERE id=old.resolution_id;
				SELECT NAME INTO tempName FROM s_ticket_resolution WHERE id=new.resolution_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.category_id IS NOT NULL && new.category_id IS NOT NULL && old.category_id!=new.category_id)
				|| ((old.category_id IS NULL) ^ (new.category_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='category_id';
				SELECT NAME INTO oldTempName FROM s_ticket_category WHERE id=old.category_id;
				SELECT NAME INTO tempName FROM s_ticket_category WHERE id=new.category_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.plan_workLoad IS NOT NULL && new.plan_workLoad IS NOT NULL && old.plan_workLoad!=new.plan_workLoad)
				|| ((old.plan_workLoad IS NULL) ^ (new.plan_workLoad IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='plan_workLoad';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.plan_workLoad, '空'), ' 到 ', IFNULL(new.plan_workLoad, '空'),'<br/>');
			END IF;
			IF((old.actual_workLoad IS NOT NULL && new.actual_workLoad IS NOT NULL && old.actual_workLoad!=new.actual_workLoad)
				|| ((old.actual_workLoad IS NULL) ^ (new.actual_workLoad IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='actual_workLoad';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.actual_workLoad, '空'), ' 到 ', IFNULL(new.actual_workLoad, '空'),'<br/>');
			END IF;
			IF((old.plan_solution_date IS NOT NULL && new.plan_solution_date IS NOT NULL && old.plan_solution_date!=new.plan_solution_date)
				|| ((old.plan_solution_date IS NULL) ^ (new.plan_solution_date IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='plan_solution_date';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.plan_solution_date, '空'), ' 到 ', IFNULL(new.plan_solution_date, '空'),'<br/>');
			END IF;
			IF((old.stage_id IS NOT NULL && new.stage_id IS NOT NULL && old.stage_id!=new.stage_id)
				|| ((old.stage_id IS NULL) ^ (new.stage_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='stage_id';
				SELECT NAME INTO oldTempName FROM s_project_stage WHERE id=old.stage_id;
				SELECT NAME INTO tempName FROM s_project_stage WHERE id=new.stage_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.frequency_id IS NOT NULL && new.frequency_id IS NOT NULL && old.frequency_id!=new.frequency_id)
				|| ((old.frequency_id IS NULL) ^ (new.frequency_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='frequency_id';
				SELECT NAME INTO oldTempName FROM s_ticket_frequency WHERE id=old.frequency_id;
				SELECT NAME INTO tempName FROM s_ticket_frequency WHERE id=new.frequency_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.test_activity_id IS NOT NULL && new.test_activity_id IS NOT NULL && old.test_activity_id!=new.test_activity_id)
				|| ((old.test_activity_id IS NULL) ^ (new.test_activity_id IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='test_activity_id';
				SELECT NAME INTO oldTempName FROM test_activity WHERE uid=old.test_activity_id;
				SELECT NAME INTO tempName FROM test_activity WHERE uid=new.test_activity_id;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF((old.problem_desc IS NOT NULL && new.problem_desc IS NOT NULL && old.problem_desc!=new.problem_desc)
				|| ((old.problem_desc IS NULL) ^ (new.problem_desc IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='problem_desc';
				SET mesText=CONCAT(mesText, '<font color ="#0000ff">', columnName,'由</font><br/> ', IFNULL(old.problem_desc, '空'), ' <br/><font color="blue"> 到 </font><br/> ', IFNULL(new.problem_desc, '空'),'<br/>');
			END IF;
			IF((old.requireItem IS NOT NULL && new.requireItem IS NOT NULL && old.requireItem!=new.requireItem)
				|| ((old.requireItem IS NULL) ^ (new.requireItem IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='requireItem';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.requireItem, '空'), ' 到 ', IFNULL(new.requireItem, '空'),'<br/>');
			END IF;
			IF((old.schedule_uid IS NOT NULL && new.schedule_uid IS NOT NULL && old.schedule_uid!=new.schedule_uid)
				|| ((old.schedule_uid IS NULL) ^ (new.schedule_uid IS NULL))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='schedule_uid';
				SELECT NAME INTO oldTempName FROM `schedule` WHERE uid=old.schedule_uid;
				SELECT NAME INTO tempName FROM `schedule` WHERE uid=new.schedule_uid;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& INT类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.int_column_1 IS NOT NULL && new.int_column_1 IS NOT NULL && old.int_column_1!=new.int_column_1)
				|| ((old.int_column_1 IS NULL) ^ (new.int_column_1 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_1, '空'), ' 到 ', IFNULL(new.int_column_1, '空'),'<br/>');
			END IF;
			IF((old.int_column_2 IS NOT NULL && new.int_column_2 IS NOT NULL && old.int_column_2!=new.int_column_2)
				|| ((old.int_column_2 IS NULL) ^ (new.int_column_2 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_2, '空'), ' 到 ', IFNULL(new.int_column_2, '空'),'<br/>');
			END IF;
			IF((old.int_column_3 IS NOT NULL && new.int_column_3 IS NOT NULL && old.int_column_3!=new.int_column_3)
				|| ((old.int_column_3 IS NULL) ^ (new.int_column_3 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_3, '空'), ' 到 ', IFNULL(new.int_column_3, '空'),'<br/>');
			END IF;
			IF((old.int_column_4 IS NOT NULL && new.int_column_4 IS NOT NULL && old.int_column_4!=new.int_column_4)
				|| ((old.int_column_4 IS NULL) ^ (new.int_column_4 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_4, '空'), ' 到 ', IFNULL(new.int_column_4, '空'),'<br/>');
			END IF;
			IF((old.int_column_5 IS NOT NULL && new.int_column_5 IS NOT NULL && old.int_column_5!=new.int_column_5)
				|| ((old.int_column_5 IS NULL) ^ (new.int_column_5 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_5, '空'), ' 到 ', IFNULL(new.int_column_5, '空'),'<br/>');
			END IF;
			IF((old.int_column_6 IS NOT NULL && new.int_column_6 IS NOT NULL && old.int_column_6!=new.int_column_6)
				|| ((old.int_column_6 IS NULL) ^ (new.int_column_6 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_6';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_6, '空'), ' 到 ', IFNULL(new.int_column_6, '空'),'<br/>');
			END IF;
			IF((old.int_column_7 IS NOT NULL && new.int_column_7 IS NOT NULL && old.int_column_7!=new.int_column_7)
				|| ((old.int_column_7 IS NULL) ^ (new.int_column_7 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_7';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_7, '空'), ' 到 ', IFNULL(new.int_column_7, '空'),'<br/>');
			END IF;
			IF((old.int_column_8 IS NOT NULL && new.int_column_8 IS NOT NULL && old.int_column_8!=new.int_column_8)
				|| ((old.int_column_8 IS NULL) ^ (new.int_column_8 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_8';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_8, '空'), ' 到 ', IFNULL(new.int_column_8, '空'),'<br/>');
			END IF;
			IF((old.int_column_9 IS NOT NULL && new.int_column_9 IS NOT NULL && old.int_column_9!=new.int_column_9)
				|| ((old.int_column_9 IS NULL) ^ (new.int_column_9 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_9';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_9, '空'), ' 到 ', IFNULL(new.int_column_9, '空'),'<br/>');
			END IF;
			IF((old.int_column_10 IS NOT NULL && new.int_column_10 IS NOT NULL && old.int_column_10!=new.int_column_10)
				|| ((old.int_column_10 IS NULL) ^ (new.int_column_10 IS NULL))) THEN
			        SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='INT_COLUMN_10';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.int_column_10, '空'), ' 到 ', IFNULL(new.int_column_10, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& INT类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DOUBLE类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.double_column_1 IS NOT NULL && new.double_column_1 IS NOT NULL && old.double_column_1!=new.double_column_1)
				|| ((old.double_column_1 IS NULL) ^ (new.double_column_1 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_1, '空'), ' 到 ', IFNULL(new.double_column_1, '空'),'<br/>');
			END IF;
			IF((old.double_column_2 IS NOT NULL && new.double_column_2 IS NOT NULL && old.double_column_2!=new.double_column_2)
				|| ((old.double_column_2 IS NULL) ^ (new.double_column_2 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_2, '空'), ' 到 ', IFNULL(new.double_column_2, '空'),'<br/>');
			END IF;
			IF((old.double_column_3 IS NOT NULL && new.double_column_3 IS NOT NULL && old.double_column_3!=new.double_column_3)
				|| ((old.double_column_3 IS NULL) ^ (new.double_column_3 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_3, '空'), ' 到 ', IFNULL(new.double_column_3, '空'),'<br/>');
			END IF;
			IF((old.double_column_4 IS NOT NULL && new.double_column_4 IS NOT NULL && old.double_column_4!=new.double_column_4)
				|| ((old.double_column_4 IS NULL) ^ (new.double_column_4 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_4, '空'), ' 到 ', IFNULL(new.double_column_4, '空'),'<br/>');
			END IF;
			IF((old.double_column_5 IS NOT NULL && new.double_column_5 IS NOT NULL && old.double_column_5!=new.double_column_5)
				|| ((old.double_column_5 IS NULL) ^ (new.double_column_5 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_5, '空'), ' 到 ', IFNULL(new.double_column_5, '空'),'<br/>');
			END IF;
			IF((old.double_column_6 IS NOT NULL && new.double_column_6 IS NOT NULL && old.double_column_6!=new.double_column_6)
				|| ((old.double_column_6 IS NULL) ^ (new.double_column_6 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_6';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_6, '空'), ' 到 ', IFNULL(new.double_column_6, '空'),'<br/>');
			END IF;
			IF((old.double_column_7 IS NOT NULL && new.double_column_7 IS NOT NULL && old.double_column_7!=new.double_column_7)
				|| ((old.double_column_7 IS NULL) ^ (new.double_column_7 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_7';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_7, '空'), ' 到 ', IFNULL(new.double_column_7, '空'),'<br/>');
			END IF;
			IF((old.double_column_8 IS NOT NULL && new.double_column_8 IS NOT NULL && old.double_column_8!=new.double_column_8)
				|| ((old.double_column_8 IS NULL) ^ (new.double_column_8 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_8';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_8, '空'), ' 到 ', IFNULL(new.double_column_8, '空'),'<br/>');
			END IF;
			IF((old.double_column_9 IS NOT NULL && new.double_column_9 IS NOT NULL && old.double_column_9!=new.double_column_9)
				|| ((old.double_column_9 IS NULL) ^ (new.double_column_9 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_9';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_9, '空'), ' 到 ', IFNULL(new.double_column_9, '空'),'<br/>');
			END IF;
			IF((old.double_column_10 IS NOT NULL && new.double_column_10 IS NOT NULL && old.double_column_10!=new.double_column_10)
				|| ((old.double_column_10 IS NULL) ^ (new.double_column_10 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DOUBLE_COLUMN_10';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.double_column_10, '空'), ' 到 ', IFNULL(new.double_column_10, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DOUBLE类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DATE类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.date_column_1 IS NOT NULL && new.date_column_1 IS NOT NULL && old.date_column_1!=new.date_column_1)
				|| ((old.date_column_1 IS NULL) ^ (new.date_column_1 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_column_1, '空'), ' 到 ', IFNULL(new.date_column_1, '空'),'<br/>');
			END IF;
			IF((old.date_column_2 IS NOT NULL && new.date_column_2 IS NOT NULL && old.date_column_2!=new.date_column_2)
				|| ((old.date_column_2 IS NULL) ^ (new.date_column_2 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_column_2, '空'), ' 到 ', IFNULL(new.date_column_2, '空'),'<br/>');
			END IF;
			IF((old.date_column_3 IS NOT NULL && new.date_column_3 IS NOT NULL && old.date_column_3!=new.date_column_3)
				|| ((old.date_column_3 IS NULL) ^ (new.date_column_3 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_column_3, '空'), ' 到 ', IFNULL(new.date_column_3, '空'),'<br/>');
			END IF;
			IF((old.date_column_4 IS NOT NULL && new.date_column_4 IS NOT NULL && old.date_column_4!=new.date_column_4)
				|| ((old.date_column_4 IS NULL) ^ (new.date_column_4 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_column_4, '空'), ' 到 ', IFNULL(new.date_column_4, '空'),'<br/>');
			END IF;
			IF((old.date_column_5 IS NOT NULL && new.date_column_5 IS NOT NULL && old.date_column_5!=new.date_column_5)
				|| ((old.date_column_5 IS NULL) ^ (new.date_column_5 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_column_5, '空'), ' 到 ', IFNULL(new.date_column_5, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Date类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DATETIME类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.date_time_column_1 IS NOT NULL && new.date_time_column_1 IS NOT NULL && old.date_time_column_1!=new.date_time_column_1)
				|| ((old.date_time_column_1 IS NULL) ^ (new.date_time_column_1 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_TIME_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_time_column_1, '空'), ' 到 ', IFNULL(new.date_time_column_1, '空'),'<br/>');
			END IF;
			IF((old.date_time_column_2 IS NOT NULL && new.date_time_column_2 IS NOT NULL && old.date_time_column_2!=new.date_time_column_2)
				|| ((old.date_time_column_2 IS NULL) ^ (new.date_time_column_2 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_TIME_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_time_column_2, '空'), ' 到 ', IFNULL(new.date_time_column_2, '空'),'<br/>');
			END IF;
			IF((old.date_time_column_3 IS NOT NULL && new.date_time_column_3 IS NOT NULL && old.date_time_column_3!=new.date_time_column_3)
				|| ((old.date_time_column_3 IS NULL) ^ (new.date_time_column_3 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_TIME_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_time_column_3, '空'), ' 到 ', IFNULL(new.date_time_column_3, '空'),'<br/>');
			END IF;
			IF((old.date_time_column_4 IS NOT NULL && new.date_time_column_4 IS NOT NULL && old.date_time_column_4!=new.date_time_column_4)
				|| ((old.date_time_column_4 IS NULL) ^ (new.date_time_column_4 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_TIME_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_time_column_4, '空'), ' 到 ', IFNULL(new.date_time_column_4, '空'),'<br/>');
			END IF;
			IF((old.date_time_column_5 IS NOT NULL && new.date_time_column_5 IS NOT NULL && old.date_time_column_5!=new.date_time_column_5)
				|| ((old.date_time_column_5 IS NULL) ^ (new.date_time_column_5 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='DATE_TIME_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.date_time_column_5, '空'), ' 到 ', IFNULL(new.date_time_column_5, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& DATETIME类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& VARCHAR类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.varchar_column_1 IS NOT NULL && new.varchar_column_1 IS NOT NULL && old.varchar_column_1!=new.varchar_column_1)
				|| ((old.varchar_column_1 IS NULL) ^ (new.varchar_column_1 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_1, '空'), ' 到 ', IFNULL(new.varchar_column_1, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_2 IS NOT NULL && new.varchar_column_2 IS NOT NULL && old.varchar_column_2!=new.varchar_column_2)
				|| ((old.varchar_column_2 IS NULL) ^ (new.varchar_column_2 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_2, '空'), ' 到 ', IFNULL(new.varchar_column_2, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_3 IS NOT NULL && new.varchar_column_3 IS NOT NULL && old.varchar_column_3!=new.varchar_column_3)
				|| ((old.varchar_column_3 IS NULL) ^ (new.varchar_column_3 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_3, '空'), ' 到 ', IFNULL(new.varchar_column_3, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_4 IS NOT NULL && new.varchar_column_4 IS NOT NULL && old.varchar_column_4!=new.varchar_column_4)
				|| ((old.varchar_column_4 IS NULL) ^ (new.varchar_column_4 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_4, '空'), ' 到 ', IFNULL(new.varchar_column_4, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_5 IS NOT NULL && new.varchar_column_5 IS NOT NULL && old.varchar_column_5!=new.varchar_column_5)
				|| ((old.varchar_column_5 IS NULL) ^ (new.varchar_column_5 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_5, '空'), ' 到 ', IFNULL(new.varchar_column_5, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_6 IS NOT NULL && new.varchar_column_6 IS NOT NULL && old.varchar_column_6!=new.varchar_column_6)
				|| ((old.varchar_column_6 IS NULL) ^ (new.varchar_column_6 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_6';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_6, '空'), ' 到 ', IFNULL(new.varchar_column_6, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_7 IS NOT NULL && new.varchar_column_7 IS NOT NULL && old.varchar_column_7!=new.varchar_column_7)
				|| ((old.varchar_column_7 IS NULL) ^ (new.varchar_column_7 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_7';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_7, '空'), ' 到 ', IFNULL(new.varchar_column_7, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_8 IS NOT NULL && new.varchar_column_8 IS NOT NULL && old.varchar_column_8!=new.varchar_column_8)
				|| ((old.varchar_column_8 IS NULL) ^ (new.varchar_column_8 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_8';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_8, '空'), ' 到 ', IFNULL(new.varchar_column_8, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_9 IS NOT NULL && new.varchar_column_9 IS NOT NULL && old.varchar_column_9!=new.varchar_column_9)
				|| ((old.varchar_column_9 IS NULL) ^ (new.varchar_column_9 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_9';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_9, '空'), ' 到 ', IFNULL(new.varchar_column_9, '空'),'<br/>');
			END IF;
			IF((old.varchar_column_10 IS NOT NULL && new.varchar_column_10 IS NOT NULL && old.varchar_column_10!=new.varchar_column_10)
				|| ((old.varchar_column_10 IS NULL) ^ (new.varchar_column_10 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='VARCHAR_COLUMN_10';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.varchar_column_10, '空'), ' 到 ', IFNULL(new.varchar_column_10, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& VARCHAR类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& BOOLEAN类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.boolean_column_1 IS NOT NULL && new.boolean_column_1 IS NOT NULL && old.boolean_column_1!=new.boolean_column_1)
				|| ((old.boolean_column_1 IS NULL) ^ (new.boolean_column_1 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='BOOLEAN_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IF(old.boolean_column_1=NULL, '空', IF(old.boolean_column_1,'是','否')), ' 到 ', IF(new.boolean_column_1=NULL, '空', IF(new.boolean_column_1,'是','否')),'<br/>');
			END IF;
			IF((old.boolean_column_2 IS NOT NULL && new.boolean_column_2 IS NOT NULL && old.boolean_column_2!=new.boolean_column_2)
				|| ((old.boolean_column_2 IS NULL) ^ (new.boolean_column_2 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='BOOLEAN_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IF(old.boolean_column_2=NULL, '空', IF(old.boolean_column_2,'是','否')), ' 到 ', IF(new.boolean_column_2=NULL, '空', IF(new.boolean_column_2,'是','否')),'<br/>');
			END IF;
			IF((old.boolean_column_3 IS NOT NULL && new.boolean_column_3 IS NOT NULL && old.boolean_column_3!=new.boolean_column_3)
				|| ((old.boolean_column_3 IS NULL) ^ (new.boolean_column_3 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='BOOLEAN_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IF(old.boolean_column_3=NULL, '空', IF(old.boolean_column_3,'是','否')), ' 到 ', IF(new.boolean_column_3=NULL, '空', IF(new.boolean_column_3,'是','否')),'<br/>');
			END IF;
			IF((old.boolean_column_4 IS NOT NULL && new.boolean_column_4 IS NOT NULL && old.boolean_column_4!=new.boolean_column_4)
				|| ((old.boolean_column_4 IS NULL) ^ (new.boolean_column_4 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='BOOLEAN_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IF(old.boolean_column_4=NULL, '空', IF(old.boolean_column_4,'是','否')), ' 到 ', IF(new.boolean_column_4=NULL, '空', IF(new.boolean_column_4,'是','否')),'<br/>');
			END IF;
			IF((old.boolean_column_5 IS NOT NULL && new.boolean_column_5 IS NOT NULL && old.boolean_column_5!=new.boolean_column_5)
				|| ((old.boolean_column_5 IS NULL) ^ (new.boolean_column_5 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='BOOLEAN_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IF(old.boolean_column_5=NULL, '空', IF(old.boolean_column_5,'是','否')), ' 到 ', IF(new.boolean_column_5=NULL, '空', IF(new.boolean_column_5,'是','否')),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& BOOLEAN类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& TEXT类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.text_column_1 IS NOT NULL && new.text_column_1 IS NOT NULL && old.text_column_1!=new.text_column_1)
				|| ((old.text_column_1 IS NULL) ^ (new.text_column_1 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='TEXT_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.text_column_1, '空'), ' 到 ', IFNULL(new.text_column_1, '空'),'<br/>');
			END IF;
			IF((old.text_column_2 IS NOT NULL && new.text_column_2 IS NOT NULL && old.text_column_2!=new.text_column_2)
				|| ((old.text_column_2 IS NULL) ^ (new.text_column_2 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='TEXT_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.text_column_2, '空'), ' 到 ', IFNULL(new.text_column_2, '空'),'<br/>');
			END IF;
			IF((old.text_column_3 IS NOT NULL && new.text_column_3 IS NOT NULL && old.text_column_3!=new.text_column_3)
				|| ((old.text_column_3 IS NULL) ^ (new.text_column_3 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='TEXT_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.text_column_3, '空'), ' 到 ', IFNULL(new.text_column_3, '空'),'<br/>');
			END IF;
			IF((old.text_column_4 IS NOT NULL && new.text_column_4 IS NOT NULL && old.text_column_4!=new.text_column_4)
				|| ((old.text_column_4 IS NULL) ^ (new.text_column_4 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='TEXT_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.text_column_4, '空'), ' 到 ', IFNULL(new.text_column_4, '空'),'<br/>');
			END IF;
			IF((old.text_column_5 IS NOT NULL && new.text_column_5 IS NOT NULL && old.text_column_5!=new.text_column_5)
				|| ((old.text_column_5 IS NULL) ^ (new.text_column_5 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='TEXT_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.text_column_5, '空'), ' 到 ', IFNULL(new.text_column_5, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& TEXT类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& URL类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF(((old.url_column_1 IS NOT NULL && new.url_column_1 IS NOT NULL && old.url_column_1!=new.url_column_1)
				|| ((old.url_column_1 IS NULL) ^ (new.url_column_1 IS NULL)))
				|| ((old.url_column_1_address IS NOT NULL && new.url_column_1_address IS NOT NULL && old.url_column_1_address!=new.url_column_1_address)
				|| ((old.url_column_1_address IS NULL) ^ (new.url_column_1_address IS NULL)))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='URL_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,'由 <a href="', IFNULL(old.url_column_1_address, ''), '" target="_blank">', IFNULL(old.url_column_1, '空')
					, '</a> 到 <a href="', IFNULL(new.url_column_1_address, ''), '" target="_blank">', IFNULL(new.url_column_1, '空'), '</a><br/>');
			END IF;
			IF(((old.url_column_2 IS NOT NULL && new.url_column_2 IS NOT NULL && old.url_column_2!=new.url_column_2)
				|| ((old.url_column_2 IS NULL) ^ (new.url_column_2 IS NULL)))
				|| ((old.url_column_2_address IS NOT NULL && new.url_column_2_address IS NOT NULL && old.url_column_2_address!=new.url_column_2_address)
				|| ((old.url_column_2_address IS NULL) ^ (new.url_column_2_address IS NULL)))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='URL_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,'由 <a href="', IFNULL(old.url_column_2_address, ''), '" target="_blank">', IFNULL(old.url_column_2, '空')
					, '</a> 到 <a href="', IFNULL(new.url_column_2_address, ''), '" target="_blank">', IFNULL(new.url_column_2, '空'), '</a><br/>');
			END IF;
			IF(((old.url_column_3 IS NOT NULL && new.url_column_3 IS NOT NULL && old.url_column_3!=new.url_column_3)
				|| ((old.url_column_3 IS NULL) ^ (new.url_column_3 IS NULL)))
				|| ((old.url_column_3_address IS NOT NULL && new.url_column_3_address IS NOT NULL && old.url_column_3_address!=new.url_column_3_address)
				|| ((old.url_column_3_address IS NULL) ^ (new.url_column_3_address IS NULL)))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='URL_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,'由 <a href="', IFNULL(old.url_column_3_address, ''), '" target="_blank">', IFNULL(old.url_column_3, '空')
					, '</a> 到 <a href="', IFNULL(new.url_column_3_address, ''), '" target="_blank">', IFNULL(new.url_column_3, '空'), '</a><br/>');
			END IF;
			IF(((old.url_column_4 IS NOT NULL && new.url_column_4 IS NOT NULL && old.url_column_4!=new.url_column_4)
				|| ((old.url_column_4 IS NULL) ^ (new.url_column_4 IS NULL)))
				|| ((old.url_column_4_address IS NOT NULL && new.url_column_4_address IS NOT NULL && old.url_column_4_address!=new.url_column_4_address)
				|| ((old.url_column_4_address IS NULL) ^ (new.url_column_4_address IS NULL)))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='URL_COLUMN_4';
				SET mesText=CONCAT(mesText, columnName,'由 <a href="', IFNULL(old.url_column_4_address, ''), '" target="_blank">', IFNULL(old.url_column_4, '空')
					, '</a> 到 <a href="', IFNULL(new.url_column_4_address, ''), '" target="_blank">', IFNULL(new.url_column_4, '空'), '</a><br/>');
			END IF;
			IF(((old.url_column_5 IS NOT NULL && new.url_column_5 IS NOT NULL && old.url_column_5!=new.url_column_5)
				|| ((old.url_column_5 IS NULL) ^ (new.url_column_5 IS NULL)))
				|| ((old.url_column_5_address IS NOT NULL && new.url_column_5_address IS NOT NULL && old.url_column_5_address!=new.url_column_5_address)
				|| ((old.url_column_5_address IS NULL) ^ (new.url_column_5_address IS NULL)))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='URL_COLUMN_5';
				SET mesText=CONCAT(mesText, columnName,'由 <a href="', IFNULL(old.url_column_5_address, ''), '" target="_blank">', IFNULL(old.url_column_5, '空')
					, '</a> 到 <a href="', IFNULL(new.url_column_5_address, ''), '" target="_blank">', IFNULL(new.url_column_5, '空'), '</a><br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& URL类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& WEB类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.web_column_1 IS NOT NULL && new.web_column_1 IS NOT NULL && old.web_column_1!=new.web_column_1)
				|| ((old.web_column_1 IS NULL) ^ (new.web_column_1 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='WEB_COLUMN_1';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.web_column_1, '空'), ' 到 ', IFNULL(new.web_column_1, '空'),'<br/>');
			END IF;
			IF((old.web_column_2 IS NOT NULL && new.web_column_2 IS NOT NULL && old.web_column_2!=new.web_column_2)
				|| ((old.web_column_2 IS NULL) ^ (new.web_column_2 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='WEB_COLUMN_2';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.web_column_2, '空'), ' 到 ', IFNULL(new.web_column_2, '空'),'<br/>');
			END IF;
			IF((old.web_column_3 IS NOT NULL && new.web_column_3 IS NOT NULL && old.web_column_3!=new.web_column_3)
				|| ((old.web_column_3 IS NULL) ^ (new.web_column_3 IS NULL))) THEN
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='WEB_COLUMN_3';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(old.web_column_3, '空'), ' 到 ', IFNULL(new.web_column_3, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& WEB类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& PERSONSINGLE类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.person_single_1 IS NOT NULL && new.person_single_1 IS NOT NULL && old.person_single_1!=new.person_single_1)
				|| ((old.person_single_1 IS NULL) ^ (new.person_single_1 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_SINGLE_1';
				SELECT  NAME INTO personNameOld FROM  person WHERE id=old.person_single_1;
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_single_1;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.person_single_2 IS NOT NULL && new.person_single_2 IS NOT NULL && old.person_single_2!=new.person_single_2)
				|| ((old.person_single_2 IS NULL) ^ (new.person_single_2 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_SINGLE_2';
				SELECT  NAME INTO personNameOld FROM  person WHERE id=old.person_single_2;
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_single_2;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.person_single_3 IS NOT NULL && new.person_single_3 IS NOT NULL && old.person_single_3!=new.person_single_3)
				|| ((old.person_single_3 IS NULL) ^ (new.person_single_3 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_SINGLE_3';
				SELECT  NAME INTO personNameOld FROM  person WHERE id=old.person_single_3;
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_single_3;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.person_single_4 IS NOT NULL && new.person_single_4 IS NOT NULL && old.person_single_4!=new.person_single_4)
				|| ((old.person_single_4 IS NULL) ^ (new.person_single_4 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_SINGLE_4';
				SELECT  NAME INTO personNameOld FROM  person WHERE id=old.person_single_4;
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_single_4;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.person_single_5 IS NOT NULL && new.person_single_5 IS NOT NULL && old.person_single_5!=new.person_single_5)
				|| ((old.person_single_5 IS NULL) ^ (new.person_single_5 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_SINGLE_5';
				SELECT  NAME INTO personNameOld FROM  person WHERE id=old.person_single_5;
				SELECT  NAME INTO personName FROM  person WHERE id=new.person_single_5;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& PERSONSINGLE类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& PERSONMULTIPLE类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.person_multiple_1 IS NOT NULL && new.person_multiple_1 IS NOT NULL && old.person_multiple_1!=new.person_multiple_1)
				|| ((old.person_multiple_1 IS NULL) ^ (new.person_multiple_1 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_MULTIPLE_1';
				SELECT GROUP_CONCAT(NAME) INTO personNameOld FROM  person WHERE LOCATE(id, old.person_multiple_1)
					AND SUBSTR(old.person_multiple_1, LOCATE(id, old.person_multiple_1)+LENGTH(id), 1) = ',' AND SUBSTR(old.person_multiple_1, LOCATE(id, old.person_multiple_1)-1, 1) = ',';
				SELECT GROUP_CONCAT(NAME) INTO personName FROM  person WHERE LOCATE(id, new.person_multiple_1)
					AND SUBSTR(new.person_multiple_1, LOCATE(id, new.person_multiple_1)+LENGTH(id), 1) = ',' AND SUBSTR(new.person_multiple_1, LOCATE(id, new.person_multiple_1)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.person_multiple_2 IS NOT NULL && new.person_multiple_2 IS NOT NULL && old.person_multiple_2!=new.person_multiple_2)
				|| ((old.person_multiple_2 IS NULL) ^ (new.person_multiple_2 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_MULTIPLE_2';
				SELECT GROUP_CONCAT(NAME) INTO personNameOld FROM  person WHERE LOCATE(id, old.person_multiple_2)
					AND SUBSTR(old.person_multiple_2, LOCATE(id, old.person_multiple_2)+LENGTH(id), 1) = ',' AND SUBSTR(old.person_multiple_2, LOCATE(id, old.person_multiple_2)-1, 1) = ',';
				SELECT GROUP_CONCAT(NAME) INTO personName FROM  person WHERE LOCATE(id, new.person_multiple_2)
					AND SUBSTR(new.person_multiple_2, LOCATE(id, new.person_multiple_2)+LENGTH(id), 1) = ',' AND SUBSTR(new.person_multiple_2, LOCATE(id, new.person_multiple_2)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.person_multiple_3 IS NOT NULL && new.person_multiple_3 IS NOT NULL && old.person_multiple_3!=new.person_multiple_3)
				|| ((old.person_multiple_3 IS NULL) ^ (new.person_multiple_3 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PERSON_MULTIPLE_3';
				SELECT GROUP_CONCAT(NAME) INTO personNameOld FROM  person WHERE LOCATE(id, old.person_multiple_3)
					AND SUBSTR(old.person_multiple_3, LOCATE(id, old.person_multiple_3)+LENGTH(id), 1) = ',' AND SUBSTR(old.person_multiple_3, LOCATE(id, old.person_multiple_3)-1, 1) = ',';
				SELECT GROUP_CONCAT(NAME) INTO personName FROM  person WHERE LOCATE(id, new.person_multiple_3)
					AND SUBSTR(new.person_multiple_3, LOCATE(id, new.person_multiple_3)+LENGTH(id), 1) = ',' AND SUBSTR(new.person_multiple_3, LOCATE(id, new.person_multiple_3)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& PERSONMULTIPLE类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& UnitSingle类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.unit_single_1 IS NOT NULL && new.unit_single_1 IS NOT NULL && old.unit_single_1!=new.unit_single_1)
				|| ((old.unit_single_1 IS NULL) ^ (new.unit_single_1 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_SINGLE_1';
				SELECT NAME INTO personNameOld FROM  unit WHERE id = old.unit_single_1;
				SELECT NAME INTO personName FROM  unit WHERE id = new.unit_single_1;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.unit_single_2 IS NOT NULL && new.unit_single_2 IS NOT NULL && old.unit_single_2!=new.unit_single_2)
				|| ((old.unit_single_2 IS NULL) ^ (new.unit_single_2 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_SINGLE_2';
				SELECT NAME INTO personNameOld FROM  unit WHERE id = old.unit_single_2;
				SELECT NAME INTO personName FROM  unit WHERE id = new.unit_single_2;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.unit_single_3 IS NOT NULL && new.unit_single_3 IS NOT NULL && old.unit_single_3!=new.unit_single_3)
				|| ((old.unit_single_3 IS NULL) ^ (new.unit_single_3 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_SINGLE_3';
				SELECT NAME INTO personNameOld FROM  unit WHERE id = old.unit_single_3;
				SELECT NAME INTO personName FROM  unit WHERE id = new.unit_single_3;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.unit_single_4 IS NOT NULL && new.unit_single_4 IS NOT NULL && old.unit_single_4!=new.unit_single_4)
				|| ((old.unit_single_4 IS NULL) ^ (new.unit_single_4 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_SINGLE_4';
				SELECT NAME INTO personNameOld FROM  unit WHERE id= old.unit_single_4;
				SELECT NAME INTO personName FROM  unit WHERE id = new.unit_single_4;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.unit_single_5 IS NOT NULL && new.unit_single_5 IS NOT NULL && old.unit_single_5!=new.unit_single_5)
				|| ((old.unit_single_5 IS NULL) ^ (new.unit_single_5 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_SINGLE_5';
				SELECT NAME INTO personNameOld FROM  unit WHERE id = old.unit_single_5;
				SELECT NAME INTO personName FROM  unit WHERE id = new.unit_single_5;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& unit类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& UNITMULTIPLE类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.unit_multiple_1 IS NOT NULL && new.unit_multiple_1 IS NOT NULL && old.unit_multiple_1!=new.unit_multiple_1)
				|| ((old.unit_multiple_1 IS NULL) ^ (new.unit_multiple_1 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_MULTIPLE_1';
				SELECT GROUP_CONCAT(NAME) INTO personNameOld FROM  unit WHERE LOCATE(id, old.unit_multiple_1)
					AND SUBSTR(old.unit_multiple_1, LOCATE(id, old.unit_multiple_1)+LENGTH(id), 1) = ',' AND SUBSTR(old.unit_multiple_1, LOCATE(id, old.unit_multiple_1)-1, 1) = ',';
				SELECT GROUP_CONCAT(NAME) INTO personName FROM  unit WHERE LOCATE(id, new.unit_multiple_1)
					AND SUBSTR(new.unit_multiple_1, LOCATE(id, new.unit_multiple_1)+LENGTH(id), 1) = ',' AND SUBSTR(new.unit_multiple_1, LOCATE(id, new.unit_multiple_1)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.unit_multiple_2 IS NOT NULL && new.unit_multiple_2 IS NOT NULL && old.unit_multiple_2!=new.unit_multiple_2)
				|| ((old.unit_multiple_2 IS NULL) ^ (new.unit_multiple_2 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_MULTIPLE_2';
				SELECT GROUP_CONCAT(NAME) INTO personNameOld FROM  unit WHERE LOCATE(id, old.unit_multiple_2)
					AND SUBSTR(old.unit_multiple_2, LOCATE(id, old.unit_multiple_2)+LENGTH(id), 1) = ',' AND SUBSTR(old.unit_multiple_2, LOCATE(id, old.unit_multiple_2)-1, 1) = ',';
				SELECT GROUP_CONCAT(NAME) INTO personName FROM  unit WHERE LOCATE(id, new.unit_multiple_2)
					AND SUBSTR(new.unit_multiple_2, LOCATE(id, new.unit_multiple_2)+LENGTH(id), 1) = ',' AND SUBSTR(new.unit_multiple_2, LOCATE(id, new.unit_multiple_2)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.unit_multiple_3 IS NOT NULL && new.unit_multiple_3 IS NOT NULL && old.unit_multiple_3!=new.unit_multiple_3)
				|| ((old.unit_multiple_3 IS NULL) ^ (new.unit_multiple_3 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='UNIT_MULTIPLE_3';
				SELECT GROUP_CONCAT(NAME) INTO personNameOld FROM  unit WHERE LOCATE(id, old.unit_multiple_3)
					AND SUBSTR(old.unit_multiple_3, LOCATE(id, old.unit_multiple_3)+LENGTH(id), 1) = ',' AND SUBSTR(old.unit_multiple_3, LOCATE(id, old.unit_multiple_3)-1, 1) = ',';
				SELECT GROUP_CONCAT(NAME) INTO personName FROM  unit WHERE LOCATE(id, new.unit_multiple_3)
					AND SUBSTR(new.unit_multiple_3, LOCATE(id, new.unit_multiple_3)+LENGTH(id), 1) = ',' AND SUBSTR(new.unit_multiple_3, LOCATE(id, new.unit_multiple_3)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& UNITMULTIPLE类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 系统标准类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
    	                IF((old.standard_column_1 IS NOT NULL && new.standard_column_1 IS NOT NULL && old.standard_column_1!=new.standard_column_1)
				|| ((old.standard_column_1 IS NULL) ^ (new.standard_column_1 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_1';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_1 WHERE id=old.standard_column_1;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_1 WHERE id=new.standard_column_1;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_2 IS NOT NULL && new.standard_column_2 IS NOT NULL && old.standard_column_2!=new.standard_column_2)
				|| ((old.standard_column_2 IS NULL) ^ (new.standard_column_2 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_2';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_2 WHERE id=old.standard_column_2;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_2 WHERE id=new.standard_column_2;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_3 IS NOT NULL && new.standard_column_3 IS NOT NULL && old.standard_column_3!=new.standard_column_3)
				|| ((old.standard_column_3 IS NULL) ^ (new.standard_column_3 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_3';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_3 WHERE id=old.standard_column_3;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_3 WHERE id=new.standard_column_3;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_4 IS NOT NULL && new.standard_column_4 IS NOT NULL && old.standard_column_4!=new.standard_column_4)
				|| ((old.standard_column_4 IS NULL) ^ (new.standard_column_4 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_4';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_4 WHERE id=old.standard_column_4;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_4 WHERE id=new.standard_column_4;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_5 IS NOT NULL && new.standard_column_5 IS NOT NULL && old.standard_column_5!=new.standard_column_5)
				|| ((old.standard_column_5 IS NULL) ^ (new.standard_column_5 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_5';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_5 WHERE id=old.standard_column_5;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_5 WHERE id=new.standard_column_5;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_6 IS NOT NULL && new.standard_column_6 IS NOT NULL && old.standard_column_6!=new.standard_column_6)
				|| ((old.standard_column_6 IS NULL) ^ (new.standard_column_6 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_6';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_6 WHERE id=old.standard_column_6;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_6 WHERE id=new.standard_column_6;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_7 IS NOT NULL && new.standard_column_7 IS NOT NULL && old.standard_column_7!=new.standard_column_7)
				|| ((old.standard_column_7 IS NULL) ^ (new.standard_column_7 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_7';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_7 WHERE id=old.standard_column_7;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_7 WHERE id=new.standard_column_7;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_8 IS NOT NULL && new.standard_column_8 IS NOT NULL && old.standard_column_8!=new.standard_column_8)
				|| ((old.standard_column_8 IS NULL) ^ (new.standard_column_8 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_8';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_8 WHERE id=old.standard_column_8;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_8 WHERE id=new.standard_column_8;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_9 IS NOT NULL && new.standard_column_9 IS NOT NULL && old.standard_column_9!=new.standard_column_9)
				|| ((old.standard_column_9 IS NULL) ^ (new.standard_column_9 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_9';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_9 WHERE id=old.standard_column_9;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_9 WHERE id=new.standard_column_9;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.standard_column_10 IS NOT NULL && new.standard_column_10 IS NOT NULL && old.standard_column_10!=new.standard_column_10)
				|| ((old.standard_column_10 IS NULL) ^ (new.standard_column_10 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='STANDARD_COLUMN_10';
				SELECT  NAME INTO personNameOld FROM  s_ticket_standard_table_10 WHERE id=old.standard_column_10;
				SELECT  NAME INTO personName FROM  s_ticket_standard_table_10 WHERE id=new.standard_column_10;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 系统标准类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& projectSingle类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.project_single_1 IS NOT NULL && new.project_single_1 IS NOT NULL && old.project_single_1!=new.project_single_1)
				|| ((old.project_single_1 IS NULL) ^ (new.project_single_1 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PROJECT_SINGLE_1';
				SELECT  NAME INTO personNameOld FROM  project WHERE id=old.project_single_1;
				SELECT  NAME INTO personName FROM  project WHERE id=new.project_single_1;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.project_single_2 IS NOT NULL && new.project_single_2 IS NOT NULL && old.project_single_2!=new.project_single_2)
				|| ((old.project_single_2 IS NULL) ^ (new.project_single_2 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PROJECT_SINGLE_2';
				SELECT  NAME INTO personNameOld FROM  project WHERE id=old.project_single_2;
				SELECT  NAME INTO personName FROM  project WHERE id=new.project_single_2;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.project_single_3 IS NOT NULL && new.project_single_3 IS NOT NULL && old.project_single_3!=new.project_single_3)
				|| ((old.project_single_3 IS NULL) ^ (new.project_single_3 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PROJECT_SINGLE_3';
				SELECT  NAME INTO personNameOld FROM  project WHERE id=old.project_single_3;
				SELECT  NAME INTO personName FROM  project WHERE id=new.project_single_3;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& projectSingle类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& projectMultiple类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF((old.project_multiple_1 IS NOT NULL && new.project_multiple_1 IS NOT NULL && old.project_multiple_1!=new.project_multiple_1)
				|| ((old.project_multiple_1 IS NULL) ^ (new.project_multiple_1 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PROJECT_MULTIPLE_1';
				SELECT  GROUP_CONCAT(NAME) INTO personNameOld FROM  project WHERE LOCATE(id, old.project_multiple_1)
					AND SUBSTR(old.project_multiple_1, LOCATE(id, old.project_multiple_1)+LENGTH(id), 1) = ',' AND SUBSTR(old.project_multiple_1, LOCATE(id, old.project_multiple_1)-1, 1) = ',';
				SELECT  GROUP_CONCAT(NAME) INTO personName FROM  project WHERE LOCATE(id, new.project_multiple_1)
					AND SUBSTR(new.project_multiple_1, LOCATE(id, new.project_multiple_1)+LENGTH(id), 1) = ',' AND SUBSTR(new.project_multiple_1, LOCATE(id, new.project_multiple_1)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			IF((old.project_multiple_2 IS NOT NULL && new.project_multiple_2 IS NOT NULL && old.project_multiple_2!=new.project_multiple_2)
				|| ((old.project_multiple_2 IS NULL) ^ (new.project_multiple_2 IS NULL))) THEN
				SET personNameOld=NULL;
				SET personName=NULL;
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PROJECT_MULTIPLE_2';
				SELECT  GROUP_CONCAT(NAME) INTO personNameOld FROM  project WHERE LOCATE(id, old.project_multiple_2)
					AND SUBSTR(old.project_multiple_2, LOCATE(id, old.project_multiple_2)+LENGTH(id), 1) = ',' AND SUBSTR(old.project_multiple_2, LOCATE(id, old.project_multiple_2)-1, 1) = ',';
				SELECT  GROUP_CONCAT(NAME) INTO personName FROM  project WHERE LOCATE(id, new.project_multiple_2)
					AND SUBSTR(new.project_multiple_2, LOCATE(id, new.project_multiple_2)+LENGTH(id), 1) = ',' AND SUBSTR(new.project_multiple_2, LOCATE(id, new.project_multiple_2)-1, 1) = ',';
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(personNameOld, '空'), ' 到 ', IFNULL(personName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& projectMultiple类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& productColumn类型扩展数据开始&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			IF(((old.product_column_1 IS NOT NULL && new.product_column_1 IS NOT NULL && old.product_column_1!=new.product_column_1)
				|| ((old.product_column_1 IS NULL) ^ (new.product_column_1 IS NULL)))
				|| ((old.product_version_1 IS NOT NULL && new.product_version_1 IS NOT NULL && old.product_version_1!=new.product_version_1)
				|| ((old.product_version_1 IS NULL) ^ (new.product_version_1 IS NULL)))
				|| ((old.product_module_1 IS NOT NULL && new.product_module_1 IS NOT NULL && old.product_module_1!=new.product_module_1)
				|| ((old.product_module_1 IS NULL) ^ (new.product_module_1 IS NULL)))) THEN
				SET oldTempName=NULL;
				SET tempName=NULL;
				SET productNameOld='';
				SET productName='';
				SET versionNameOld='';
				SET versionName='';
				SET moduleNameOld='';
				SET moduleName='';
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PRODUCT_1';
				SELECT NAME INTO productNameOld FROM product WHERE product_uid=old.product_column_1;
				SELECT NAME INTO productName FROM product WHERE product_uid=new.product_column_1;
				IF(((old.product_version_1 IS NOT NULL && new.product_version_1 IS NOT NULL && old.product_version_1!=new.product_version_1)
					|| ((old.product_version_1 IS NULL) ^ (new.product_version_1 IS NULL)))
					|| ((old.product_module_1 IS NOT NULL && new.product_module_1 IS NOT NULL && old.product_module_1!=new.product_module_1)
					|| ((old.product_module_1 IS NULL) ^ (new.product_module_1 IS NULL)))) THEN
					SELECT VERSION INTO versionName FROM product_version WHERE product_uid = new.product_column_1 AND product_version_uid = new.product_version_1;
					SELECT VERSION INTO versionNameOld FROM product_version WHERE product_uid = old.product_column_1 AND product_version_uid = old.product_version_1;
					IF((old.product_module_1 IS NOT NULL && new.product_module_1 IS NOT NULL && old.product_module_1!=new.product_module_1)
						|| ((old.product_module_1 IS NULL) ^ (new.product_module_1 IS NULL))) THEN
						SELECT NAME INTO moduleName  FROM product_version_module WHERE product_uid = new.product_column_1 AND product_version_uid = new.product_version_1 AND module_uid = new.product_module_1;
						SELECT NAME INTO moduleNameOld  FROM product_version_module WHERE product_uid = old.product_column_1 AND product_version_uid = old.product_version_1 AND module_uid = old.product_module_1;
					END IF;
				END IF;
				IF(productNameOld IS NOT NULL && productNameOld!='') THEN
					SET oldTempName=productNameOld;
				END IF;
				IF(versionNameOld IS NOT NULL && versionNameOld!='') THEN
					SET oldTempName=CONCAT(oldTempName, ",", versionNameOld);
				END IF;
				IF(moduleNameOld IS NOT NULL && moduleNameOld!='') THEN
					SET oldTempName=CONCAT(oldTempName, ",", moduleNameOld);
				END IF;
				IF(productName IS NOT NULL && productName!='') THEN
					SET tempName=productName;
				END IF;
				IF(versionName IS NOT NULL && versionName!='') THEN
					SET tempName=CONCAT(tempName, ",", versionName);
				END IF;
				IF(moduleName IS NOT NULL && moduleName!='') THEN
					SET tempName=CONCAT(tempName, ",", moduleName);
				END IF;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF(((old.product_column_2 IS NOT NULL && new.product_column_2 IS NOT NULL && old.product_column_2!=new.product_column_2)
				|| ((old.product_column_2 IS NULL) ^ (new.product_column_2 IS NULL)))
				|| ((old.product_version_2 IS NOT NULL && new.product_version_2 IS NOT NULL && old.product_version_2!=new.product_version_2)
				|| ((old.product_version_2 IS NULL) ^ (new.product_version_2 IS NULL)))
				|| ((old.product_module_2 IS NOT NULL && new.product_module_2 IS NOT NULL && old.product_module_2!=new.product_module_2)
				|| ((old.product_module_2 IS NULL) ^ (new.product_module_2 IS NULL)))) THEN
				SET oldTempName='';
				SET tempName='';
				SET productNameOld='';
				SET productName='';
				SET versionNameOld='';
				SET versionName='';
				SET moduleNameOld='';
				SET moduleName='';
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PRODUCT_2';
				SELECT NAME INTO productNameOld FROM product WHERE product_uid=old.product_column_2;
				SELECT NAME INTO productName FROM product WHERE product_uid=new.product_column_2;
				IF(((old.product_version_2 IS NOT NULL && new.product_version_2 IS NOT NULL && old.product_version_2!=new.product_version_2)
					|| ((old.product_version_2 IS NULL) ^ (new.product_version_2 IS NULL)))
					|| ((old.product_module_2 IS NOT NULL && new.product_module_2 IS NOT NULL && old.product_module_2!=new.product_module_2)
					|| ((old.product_module_2 IS NULL) ^ (new.product_module_2 IS NULL)))) THEN
					SELECT VERSION INTO versionName FROM product_version WHERE product_uid = new.product_column_2 AND product_version_uid = new.product_version_2;
					SELECT VERSION INTO versionNameOld FROM product_version WHERE product_uid = old.product_column_2 AND product_version_uid = old.product_version_2;
					IF((old.product_module_2 IS NOT NULL && new.product_module_2 IS NOT NULL && old.product_module_2!=new.product_module_2)
						|| ((old.product_module_2 IS NULL) ^ (new.product_module_2 IS NULL))) THEN
						SELECT NAME INTO moduleName  FROM product_version_module WHERE product_uid = new.product_column_2 AND product_version_uid = new.product_version_2 AND module_uid = new.product_module_2;
						SELECT NAME INTO moduleNameOld  FROM product_version_module WHERE product_uid = old.product_column_2 AND product_version_uid = old.product_version_2 AND module_uid = old.product_module_2;
					END IF;
				END IF;
				IF(productNameOld IS NOT NULL && productNameOld!='') THEN
					SET oldTempName=productNameOld;
				END IF;
				IF(versionNameOld IS NOT NULL && versionNameOld!='') THEN
					SET oldTempName=CONCAT(oldTempName, ",", versionNameOld);
				END IF;
				IF(moduleNameOld IS NOT NULL && moduleNameOld!='') THEN
					SET oldTempName=CONCAT(oldTempName, ",", moduleNameOld);
				END IF;
				IF(productName IS NOT NULL && productName!='') THEN
					SET tempName=productName;
				END IF;
				IF(versionName IS NOT NULL && versionName!='') THEN
					SET tempName=CONCAT(tempName, ",", versionName);
				END IF;
				IF(moduleName IS NOT NULL && moduleName!='') THEN
					SET tempName=CONCAT(tempName, ",", moduleName);
				END IF;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			IF(((old.product_column_3 IS NOT NULL && new.product_column_3 IS NOT NULL && old.product_column_3!=new.product_column_3)
				|| ((old.product_column_3 IS NULL) ^ (new.product_column_3 IS NULL)))
				|| ((old.product_version_3 IS NOT NULL && new.product_version_3 IS NOT NULL && old.product_version_3!=new.product_version_3)
				|| ((old.product_version_3 IS NULL) ^ (new.product_version_3 IS NULL)))
				|| ((old.product_module_3 IS NOT NULL && new.product_module_3 IS NOT NULL && old.product_module_3!=new.product_module_3)
				|| ((old.product_module_3 IS NULL) ^ (new.product_module_3 IS NULL)))) THEN
				SET oldTempName='';
				SET tempName='';
				SET productNameOld='';
				SET productName='';
				SET versionNameOld='';
				SET versionName='';
				SET moduleNameOld='';
				SET moduleName='';
				SELECT  page_entity_column.column_name INTO columnName
					FROM page_entity_column ,page_defined_column
					WHERE page_entity_column.column_id = page_defined_column.column_id AND page_entity_column.entity_id=10 AND page_defined_column.column_name='PRODUCT_3';
				SELECT NAME INTO productNameOld FROM product WHERE product_uid=old.product_column_3;
				SELECT NAME INTO productName FROM product WHERE product_uid=new.product_column_3;
				IF(((old.product_version_3 IS NOT NULL && new.product_version_3 IS NOT NULL && old.product_version_3!=new.product_version_3)
					|| ((old.product_version_3 IS NULL) ^ (new.product_version_3 IS NULL)))
					|| ((old.product_module_3 IS NOT NULL && new.product_module_3 IS NOT NULL && old.product_module_3!=new.product_module_3)
					|| ((old.product_module_3 IS NULL) ^ (new.product_module_3 IS NULL)))) THEN
					SELECT VERSION INTO versionName FROM product_version WHERE product_uid = new.product_column_3 AND product_version_uid = new.product_version_3;
					SELECT VERSION INTO versionNameOld FROM product_version WHERE product_uid = old.product_column_3 AND product_version_uid = old.product_version_3;
					IF((old.product_module_3 IS NOT NULL && new.product_module_3 IS NOT NULL && old.product_module_3!=new.product_module_3)
						|| ((old.product_module_3 IS NULL) ^ (new.product_module_3 IS NULL))) THEN
						SELECT NAME INTO moduleName  FROM product_version_module WHERE product_uid = new.product_column_3 AND product_version_uid = new.product_version_3 AND module_uid = new.product_module_3;
						SELECT NAME INTO moduleNameOld  FROM product_version_module WHERE product_uid = old.product_column_3 AND product_version_uid = old.product_version_3 AND module_uid = old.product_module_3;
					END IF;
				END IF;
				IF(productNameOld IS NOT NULL && productNameOld!='') THEN
					SET oldTempName=productNameOld;
				END IF;
				IF(versionNameOld IS NOT NULL && versionNameOld!='') THEN
					SET oldTempName=CONCAT(oldTempName, ",", versionNameOld);
				END IF;
				IF(moduleNameOld IS NOT NULL && moduleNameOld!='') THEN
					SET oldTempName=CONCAT(oldTempName, ",", moduleNameOld);
				END IF;
				IF(productName IS NOT NULL && productName!='') THEN
					SET tempName=productName;
				END IF;
				IF(versionName IS NOT NULL && versionName!='') THEN
					SET tempName=CONCAT(tempName, ",", versionName);
				END IF;
				IF(moduleName IS NOT NULL && moduleName!='') THEN
					SET tempName=CONCAT(tempName, ",", moduleName);
				END IF;
				SET mesText=CONCAT(mesText, columnName,' 由 ', IFNULL(oldTempName, '空'), ' 到 ', IFNULL(tempName, '空'),'<br/>');
			END IF;
			/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& productColumn类型扩展数据结束&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
			SELECT task_uid INTO taskUid FROM workflow_task_ticket WHERE ticket_uid=new.uid LIMIT 1;
			SELECT NAME INTO statusNameOld FROM s_ticket_status WHERE id=old.status_id;
			SELECT NAME INTO statusName FROM s_ticket_status WHERE id=new.status_id;
			IF(mesText IS NOT NULL && mesText!='') THEN
				INSERT INTO workflow_history (task_uid, from_status_id, from_status_name, to_status_id, to_status_name, operate_time, operator_id, former_disposer_id, next_disposer_id, comm)
					VALUE (taskUid, old.status_id, statusNameOld, new.status_id, statusName, NOW(), new.modifier_id, IFNULL(old.disposer_id, IF(old.dispose_role_id IS NULL, NULL, 0-old.dispose_role_id)), IFNULL(new.disposer_id, IF(new.dispose_role_id IS NULL, NULL, 0-new.dispose_role_id)), mesText);
			END IF;
			END IF;
	END;
$$

CREATE
    /*!50017 DEFINER = 'root'@'localhost' */
    TRIGGER `tri_user_after_insert` AFTER INSERT ON `user`
    FOR EACH ROW BEGIN
      /* 人员新建时，个人中心-工作面板，默认授予我的日历、我的记事、工作任务、项目缺陷、项目日志、里程碑、定期报告 */
      INSERT INTO r_user_element_auth VALUES(new.id,'10');
      INSERT INTO r_user_element_auth VALUES(new.id,'5');
      INSERT INTO r_user_element_auth VALUES(new.id,'2');
      INSERT INTO r_user_element_auth VALUES(new.id,'6');
      INSERT INTO r_user_element_auth VALUES(new.id,'7');
      INSERT INTO r_user_element_auth VALUES(new.id,'8');
      INSERT INTO r_user_element_auth VALUES(new.id,'1');
      /* 人员新建时，个人中心-工作面板，默认授予我的日历、我的记事、工作任务、项目缺陷、项目日志、里程碑、定期报告 */
      INSERT INTO r_user_surface_auth VALUES(new.id,'10',1,1,0,300,1,0);
      INSERT INTO r_user_surface_auth VALUES(new.id,'5',1,1,0,300,2,0);
      INSERT INTO r_user_surface_auth VALUES(new.id,'2',1,1,0,300,3,0);
      INSERT INTO r_user_surface_auth VALUES(new.id,'6',1,1,0,300,4,0);
      INSERT INTO r_user_surface_auth VALUES(new.id,'7',1,1,0,300,5,0);
      INSERT INTO r_user_surface_auth VALUES(new.id,'8',1,1,0,300,6,0);
      INSERT INTO r_user_surface_auth VALUES(new.id,'1',1,1,0,300,7,0);
      /* 人员新建时，个人中心，默认授予工作面板、日报管理、我的流程、我的考勤、工作历史、个人设置 */
      INSERT INTO r_user_element_auth VALUES(new.id,'21000000000000qwe00000003000000b');
      INSERT INTO r_user_element_auth VALUES(new.id,'20000000000000qwe00000000000000b');
      INSERT INTO r_user_element_auth VALUES(new.id,'30000000000000qwe00000000000000c');
      INSERT INTO r_user_element_auth VALUES(new.id,'41000000000000qwe00000050000000d');
      INSERT INTO r_user_element_auth VALUES(new.id,'40000000000000qwe00000000000000d');
      INSERT INTO r_user_element_auth VALUES(new.id,'10000000000000qwe00000000000000a');
      INSERT INTO r_user_element_auth VALUES(new.id,'60000000000000qwe00000000000000f');
      INSERT INTO r_user_element_auth VALUES(new.id,'80000000000000qwe00000000000000h');
END;
$$

DELIMITER ;