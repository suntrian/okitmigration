use pms;

-- ----------------------------
-- Trigger structure for tri_assessment_applicant_before_delete
-- ----------------------------
CREATE TRIGGER `tri_assessment_applicant_before_delete` BEFORE DELETE ON `assessment_applicant` FOR EACH ROW
BEGIN
        SET @id = old.id;
        SET @report_id = old.report_id;
        DELETE FROM temp_task WHERE temp_task.Type = 2 and temp_task.turn_url = CONCAT('openWorkReport.action?applicantID=', @id);
        DELETE FROM assessment_report WHERE assessment_report.id = @report_id;
END


-- ----------------------------
-- Trigger structure for tri_assessment_executive_before_delete
-- ----------------------------
CREATE TRIGGER `tri_assessment_executive_before_delete` BEFORE DELETE ON `assessment_executive` FOR EACH ROW
BEGIN
        set @id = old.id;
        delete FROM assessment_record where assessment_record.assessment_executive = @id;
END


-- ----------------------------
-- Trigger structure for tri_assessment_record_before_delete
-- ----------------------------
CREATE TRIGGER `tri_assessment_record_before_delete` BEFORE DELETE ON `assessment_record` FOR EACH ROW
BEGIN
        SET @id = old.id;
        DELETE FROM temp_task WHERE temp_task.Type = 2 and temp_task.turn_url = CONCAT('performanceExam.action?assessmentID=', @id);
END


-- ----------------------------
-- Trigger structure for tri_format_item_edition_after_insert
-- ----------------------------
CREATE TRIGGER `tri_format_item_edition_after_insert` AFTER INSERT
ON `format_item_edition` FOR EACH ROW
BEGIN
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

-- ----------------------------
-- Trigger structure for tri_format_item_edition_after_update
-- ----------------------------
CREATE TRIGGER `tri_format_item_edition_after_update` AFTER UPDATE
ON `format_item_edition` FOR EACH ROW
BEGIN
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


-- ----------------------------
-- Trigger structure for tri_project_init_after_insert
-- ----------------------------
CREATE TRIGGER `tri_project_init_after_insert` AFTER INSERT ON `project` FOR EACH ROW
BEGIN
		DECLARE productUid VARCHAR(32);
 		SELECT     REPLACE(UUID(),'-','') INTO productUid FROM DUAL;

		INSERT INTO product (product_uid,NAME,tag,ORD,pm_person_id,creator_id,create_time,level_id,is_default,is_deleted,is_share) 
		VALUES (productUid,'新产品','PDT',1000,new.create_userid,new.create_userid,new.create_date,1,0,0,0);
		
		INSERT INTO r_product_project(product_uid,project_id,is_owned) 
		VALUES (productUid,new.id,1);
END


-- ----------------------------
-- Trigger structure for tri_project_after_update
-- ----------------------------
CREATE TRIGGER `tri_project_after_update` AFTER UPDATE ON `project` FOR EACH ROW
BEGIN
		IF(old.is_deleted=0 && new.is_deleted=1) THEN
			UPDATE task SET task.status=7 WHERE task.project_id=old.id AND task.status<>5;
		END IF;
END


-- ----------------------------
-- Trigger structure for tri_r_fromat_itemfile_after_insert
-- ----------------------------
CREATE TRIGGER `tri_r_fromat_itemfile_after_insert` AFTER INSERT ON `r_format_itemfile` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_r_format_itemfile_before_delete
-- ----------------------------
CREATE TRIGGER `tri_r_format_itemfile_before_delete` BEFORE DELETE ON `r_format_itemfile` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_r_format_items_after_insert
-- ----------------------------
CREATE TRIGGER `tri_r_format_items_after_insert` AFTER INSERT ON `r_format_items` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_r_format_items_after_delete
-- ----------------------------
CREATE TRIGGER `tri_r_format_items_after_delete` AFTER DELETE ON `r_format_items` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_r_format_section_item_after_insert
-- ----------------------------
CREATE TRIGGER tri_r_format_section_item_after_insert AFTER INSERT
ON r_format_section_item FOR EACH ROW
BEGIN
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
    `operate_time`
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
      new.operate_time
    ) ;
  END IF ;
END;

-- ----------------------------
-- Trigger structure for tri_r_format_section_item_after_update
-- ----------------------------
CREATE TRIGGER tri_r_format_section_item_after_update AFTER UPDATE
ON r_format_section_item FOR EACH ROW
BEGIN
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
  /*节点变化*/
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
    `operate_time`
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
      new.operate_time
    ) ;
  END IF ;
END;


-- ----------------------------
-- Trigger structure for tri_r_resource_file_after_insert
-- ----------------------------
CREATE TRIGGER `tri_r_resource_file_after_insert` AFTER INSERT ON `r_resource_file` FOR EACH ROW
BEGIN
	if(new.fileuse_uid='6') THEN
		INSERT INTO 
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'9',NOW(),new.creator_id,'',0);
	else		
		INSERT INTO 
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'6',NOW(),new.creator_id,'',0);		
	END IF;
END


-- ----------------------------
-- Trigger structure for tri_r_resource_file_after_update
-- ----------------------------
CREATE TRIGGER `tri_r_resource_file_after_update` AFTER UPDATE ON `r_resource_file` FOR EACH ROW
BEGIN
	IF(new.fileuse_uid='6') THEN
		INSERT INTO 
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'9',NOW(),new.creator_id,'',1);
	ELSE		
		INSERT INTO 
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.file_id,'6',NOW(),new.creator_id,'',1);		
	END IF;
END


-- ----------------------------
-- Trigger structure for tri_r_resource_tag_after_insert
-- ----------------------------
CREATE TRIGGER `tri_r_resource_tag_after_insert` AFTER INSERT ON `r_resource_tag` FOR EACH ROW
BEGIN
	INSERT INTO 
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (new.resource_uid,'8',NOW(),0,new.tag,0);
END


-- ----------------------------
-- Trigger structure for tri_r_resource_tag_after_delete
-- ----------------------------
CREATE TRIGGER `tri_r_resource_tag_after_delete` AFTER DELETE ON `r_resource_tag` FOR EACH ROW
BEGIN
	INSERT INTO 
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (old.resource_uid,'8',NOW(),0,old.tag,1);
END


-- ----------------------------
-- Trigger structure for tri_recurring_personal_report_update
-- ----------------------------
CREATE TRIGGER `tri_recurring_personal_report_update` AFTER UPDATE ON `recurring_personal_report` FOR EACH ROW
BEGIN
    IF(new.is_deleted = 1) THEN
		DELETE FROM temp_task WHERE source_uid= old.uid;
    END IF;   
END


-- ----------------------------
-- Trigger structure for tri_resource_after_insert
-- ----------------------------
CREATE TRIGGER `tri_resource_after_insert` AFTER INSERT ON `resource` FOR EACH ROW
BEGIN
	INSERT INTO 
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (new.uid,'2',NOW(),new.creator_id,new.name,0);
	IF(new.comm IS NOT NULL) THEN	
		if(new.comm!='')THEN
			INSERT INTO 
			full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
			VALUES (new.uid,'3',NOW(),new.creator_id,new.comm,0);
		END IF;
	END IF;
END


-- ----------------------------
-- Trigger structure for tri_resource_after_update
-- ----------------------------
CREATE TRIGGER `tri_resource_after_update` AFTER UPDATE ON `resource` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_resource_edition_after_insert
-- ----------------------------
CREATE TRIGGER `tri_resource_edition_after_insert` AFTER INSERT ON `resource_edition` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_resource_edition_after_update
-- ----------------------------
CREATE TRIGGER `tri_resource_edition_after_update` AFTER UPDATE ON `resource_edition` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_resource_facet_after_insert
-- ----------------------------
CREATE TRIGGER `tri_resource_facet_after_insert` AFTER INSERT ON `resource_facet` FOR EACH ROW
BEGIN
	INSERT INTO 
	full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (new.uid,'7',NOW(),0,new.name,0);
END


-- ----------------------------
-- Trigger structure for tri_resource_facet_after_update
-- ----------------------------
CREATE TRIGGER `tri_resource_facet_after_update` AFTER UPDATE ON `resource_facet` FOR EACH ROW
BEGIN
	IF (new.name!=old.name OR new.comm!=old.comm) THEN
		INSERT INTO 
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (new.uid,'7',NOW(),0,new.name,0);
		INSERT INTO 
		full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
		VALUES (old.uid,'7',NOW(),0,old.name,1);
	END IF;
END


-- ----------------------------
-- Trigger structure for tri_resource_facet_after_delete
-- ----------------------------
CREATE TRIGGER `tri_resource_facet_after_delete` AFTER DELETE ON `resource_facet` FOR EACH ROW
BEGIN
	INSERT INTO full_text_source(source_uid,type_uid,create_time,creator_id,content,STATUS)
	VALUES (old.uid,'7',NOW(),0,old.name,1);
END


-- ----------------------------
-- Trigger structure for tri_s_currency_insert_after_insert
-- ----------------------------
CREATE TRIGGER `tri_s_currency_insert_after_insert` AFTER INSERT ON `s_currency` FOR EACH ROW
BEGIN
	INSERT INTO r_currency_parities (currency_id,currency_parities) (SELECT sc.id,1 FROM s_currency sc WHERE sc.id NOT IN (SELECT rp.currency_id FROM r_currency_parities rp));
    END


-- ----------------------------
-- Trigger structure for tri_s_level_insert_after_insert
-- ----------------------------
CREATE TRIGGER `tri_s_level_insert_after_insert` AFTER INSERT ON `s_level` FOR EACH ROW
BEGIN
	INSERT INTO level_point(level_id,POINT)  (SELECT s_level.id,1 FROM s_level  WHERE s_level.id NOT IN (SELECT level_id FROM level_point));
END


-- ----------------------------
-- Trigger structure for tri_task_after_insert
-- ----------------------------
CREATE TRIGGER `tri_task_after_insert` AFTER INSERT ON `task` FOR EACH ROW
BEGIN    
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
       	/*定义里程碑发送的人员*/	
		DECLARE cursorName2 CURSOR FOR  (SELECT person.id,person.name FROM project,person  WHERE project.leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
					UNION 
						(SELECT person.id,person.name FROM project,person WHERE project.quality_leader_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
					UNION 
						(SELECT person.id,person.name FROM project,person WHERE project.officer_id=person.id AND project.id=new.project_id AND person.is_deleted=FALSE)
					UNION 
						(SELECT p.id,p.name FROM project_person pro,person p WHERE pro.user_id =p.id AND pro.project_id=new.project_id AND p.is_deleted=FALSE); 						          
       DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET STOP=1;
      
	       IF(new.update_user_id)THEN
		   SET mesUserId=new.update_user_id;
	       END IF;
	       IF(!new.update_user_id)THEN
		   SET mesUserId=new.user_id;
	       END IF;
			
		 IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/
              INSERT INTO 
		task_log(taskUID,user_id,content,create_date,TYPE)
		VALUES(new.uid,mesUserId,CONCAT(NOW(),':新添加了此任务'),NOW(),12);
               END IF;
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
END


-- ----------------------------
-- Trigger structure for tri_task_before_update
-- ----------------------------
CREATE TRIGGER `tri_task_before_update` BEFORE UPDATE ON `task` FOR EACH ROW
BEGIN
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
END


-- ----------------------------
-- Trigger structure for tri_task_after_update
-- ----------------------------
CREATE TRIGGER `tri_task_after_update` AFTER UPDATE ON `task` FOR EACH ROW
BEGIN	
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
						    
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET STOP=1;
	
	      IF(new.update_user_id IS NULL) THEN
		   SET mesUserId=new.user_id;
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
		IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/	
			INSERT INTO
			task_log(taskUID,user_id,content,create_date,TYPE)
			VALUES(old.uid,mesUserId,CONCAT('任务名称修改为:',new.name),NOW(),8);
		 END IF;
			IF(new.Milestone=0) THEN 
			   SET mesText=CONCAT(mesText,'<br>任务名称修改为:<FONT color=#0000ff>',new.name,'</FONT>');
			END IF;
			IF(new.Milestone=1) THEN 
			    SET mesText=CONCAT(mesText,'<br>里程碑名称修改为:<FONT color=#0000ff>',new.name,'</FONT>');
			END IF;
			SET flag  = 1;
		END IF;
		IF(old.start!=new.start) THEN
		IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/	
			INSERT INTO
			task_log(taskUID,user_id,content,create_date,TYPE)
			VALUES(old.uid,mesUserId,CONCAT('开始时间修改为:',new.start),NOW(),1);
		END IF;
			IF(new.Milestone=0) THEN 
			  SET mesText=CONCAT(mesText,'<br>开始时间修改为:<FONT color=#0000ff>',new.start,'</FONT>');
			END IF;
			IF(new.Milestone=1) THEN 
			IF(new.start!='') THEN
			     SET mesText=CONCAT(mesText,'<br>开始时间修改为:<FONT color=#0000ff>',DATE_FORMAT(new.start,'%Y-%m-%d'),'</FONT>');
			END IF;
			END IF;			
			SET flag  = 1;
		END IF;
		IF(old.actualStart!=new.actualStart) THEN
		IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/	
			INSERT INTO
			task_log(taskUID,user_id,content,create_date,TYPE)
			VALUES(old.uid,mesUserId,CONCAT('实际开始时间修改为:',new.actualStart),NOW(),1);
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
			task_log(taskUID,user_id,content,create_date,TYPE)
			VALUES(old.uid,mesUserId,CONCAT('实际结束时间修改为:',new.ActualFinish),NOW(),1);
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
			task_log(taskUID,user_id,content,create_date,TYPE)
			VALUES(old.uid,mesUserId,CONCAT('完成比例从：',old.percentcomplete,'% 修改为:',new.percentcomplete,'%'),NOW(),6);	
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
			task_log(taskUID,user_id,content,create_date,TYPE)
			VALUES(old.uid,mesUserId,CONCAT('任务状态修改为:',tempName),NOW(),2);
			END IF;
			SET mesText=CONCAT(mesText,'<br>状态修改为:<FONT color=#0000ff>',tempName,'</FONT>');
			SET flag  = 1;
		END IF;
		IF(old.catery!=new.catery) THEN	
			SELECT NAME INTO tempName FROM s_task_catery WHERE id = new.catery;
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
			VALUES(old.uid,mesUserId,CONCAT('任务所属里程碑修改为:',tempName),NOW(),14);
			END IF;
			SET mesText=CONCAT(mesText,'<br>所属里程碑修改为:<FONT color=#0000ff>',tempName,'</FONT>');
			SET flag  = 1;
		END IF;
			IF(old.is_default!=new.is_default && new.is_default) THEN	
			IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/		
			INSERT INTO
			task_log(taskUID,user_id,content,create_date,TYPE)
			VALUES(old.uid,mesUserId,CONCAT('任务里程碑的关联状态设置为:','默认'),NOW(),15);
			END IF;
			SET mesText=CONCAT(mesText,'<br>里程碑的关联状态设置为:<FONT color=#0000ff>','默认','</FONT>');
			SET flag  = 1;
		END IF;
		
		IF(old.product_uid != new.product_uid || old.product_version_uid != new.product_version_uid || old.module_uid != new.module_uid) THEN	
		SELECT NAME INTO productName FROM product WHERE product_uid = new.product_uid;
		SELECT VERSION INTO versionName FROM product_version WHERE product_uid = new.product_uid and product_version_uid = new.product_version_uid;
		SELECT NAME INTO moduleName  FROM product_version_module WHERE product_uid = new.product_uid and product_version_uid = new.product_version_uid and module_uid = new.module_uid;
		IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/	
			IF(productName IS NOT NULL) then
				SET mesProduct=CONCAT(mesProduct,'任务关联产品修改，产品：',productName);
				SET mesText=CONCAT(mesText,'<br>关联产品修改为，产品：<FONT color=#0000ff>',productName,'</FONT>');
				ELSE
				SET mesProduct=CONCAT('取消了任务与产品的关联');
				SET mesText=CONCAT(mesText,'<br>取消了任务与产品的关联');
			END IF;
			IF(versionName IS NOT NULL) then
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
	IF(old.deliverable_description!=new.deliverable_description) THEN
	IF(new.parent_uid IS NOT NULL && new.Milestone=0) THEN/*不为根任务*/	
		INSERT INTO
		task_log(taskUID,user_id,content,create_date,TYPE)
		VALUES(old.uid,mesUserId,CONCAT('交付成果修改为:',new.deliverable_description),NOW(),4);
	END IF;
		SET mesText=CONCAT(mesText,'<br>交付成果修改为:<FONT color=#0000ff>',new.deliverable_description,'</FONT>');
		SET flag  = 1;
	END IF;
END


-- ----------------------------
-- Trigger structure for tir_task_predecessorlink_before_insert
-- ----------------------------
CREATE TRIGGER `tir_task_predecessorlink_before_insert` BEFORE INSERT ON `task_predecessorlink` FOR EACH ROW
BEGIN	
	IF(FIND_IN_SET(new.taskUID,calc_all_predecessortask_id(new.PredecessorUID))>0 && new.type=1) 
	THEN
		INSERT INTO `s_task_type`(`id`,`name`,`ord`,`comm`,`is_candelete`,`is_default`) VALUES ( '1','任务出现循环依赖','004','xx','0','0');
	END IF;
END


-- ----------------------------
-- Trigger structure for tri_user_after_insert
-- ----------------------------
CREATE TRIGGER `tri_user_after_insert` AFTER INSERT ON `user` FOR EACH ROW 
BEGIN
	INSERT INTO act_id_user (ID_,FIRST_,PWD_) VALUES (new.id,new.username,new.password);
	INSERT INTO r_sysuser_actuser(sysuser_id,activiti_uid) VALUES (new.id,new.id);
END
